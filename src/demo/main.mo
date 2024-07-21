//  ----------- Decription
//  This Motoko file contains the logic of the backend canister.

//  ----------- Imports

//  Imports from Motoko Base Library
import Array        "mo:base/Array";
import Bool         "mo:base/Bool";
import Float        "mo:base/Float";
import Hash         "mo:base/Hash";
import Int64        "mo:base/Int64";
import Iter         "mo:base/Iter";
import Nat          "mo:base/Nat";
import Nat64        "mo:base/Nat64";
import Text         "mo:base/Text";
import Time         "mo:base/Time";
import Timer         "mo:base/Timer";
import TrieMap      "mo:base/TrieMap";
import Result       "mo:base/Result";

//  Imports from helpers, utils, & types
import Hex          "lib/Hex";
import T            "types";
import Helpers      "helpers";

//  Imports from external interfaces
import Supersolid   "supersolid";

shared actor class DEMO() = this {

  //  ----------- Variables
  // Supersolid variables
  private stable var request_timer_period : Timer.Duration = #seconds (60 * 60);
  private stable var request_timer : Nat = 0;
  private stable var request_index : Nat = 0;

  // Chain variables
  private stable var arb_bal : Nat64 = 0;
  private stable var base_bal : Nat64 = 0;
  let arb_id : Nat64 = 42161;
  let base_id : Nat64 = 8453;

  //  ----------- State
  private stable var logEntries : [(Nat, T.Entry)] = [];
  private let log : TrieMap.TrieMap<Nat, T.Entry> = TrieMap.fromEntries<Nat, T.Entry>(logEntries.vals(), Nat.equal, Hash.hash);

  //  ----------- Configure external actors
  let S = actor "y24iv-baaaa-aaaal-qjhea-cai" : Supersolid.Self;

  //  ----------- Public functions
  public func nat64_to_hex(n : Nat64) : async Hex.Hex {
    return "0x" # Text.trimStart(Helpers.nat64_to_hex(n), #char '0');
  };

  public func hex_to_nat64(t : Hex.Hex) : async Result.Result<Nat64, Text> {
    Helpers.hex_to_nat64(t);
  };

  public func get_request_hex(destination_chain : Nat64, destination_address : Text, eth_amount : Float) : async Hex.Hex {
    let chain = Helpers.nat64_to_hex(destination_chain);
    let recipient = Text.trimStart(Text.toLowercase(destination_address), #text "0x");
    let amount = Helpers.nat64_to_hex(Int64.toNat64(Float.toInt64(Float.mul(eth_amount, Float.pow(10, 18)))));

    return "0x" # chain # recipient # amount;
  };

  public func decode_request_data(h : Hex.Hex) : async Result.Result<T.Request, Text> {
    _decode_request_data(h)
  };

  public func get_balances() : async T.BalancesResult {
    await _update_balances();
  };

  public func poll_requests() : async [Supersolid.ServiceRequest] {
    await _get_requests();
  };

  public func turn_on() : async T.BalancesResult {
    let balances = await _update_balances();
    request_timer := Timer.recurringTimer<system>(request_timer_period, _process_requests);
    balances;
  };

  public func turn_off() : async T.BalancesResult {
    Timer.cancelTimer(request_timer);
    await _update_balances();
  };

  //  ----------- Directly called private functions
  private func _process_requests() : async () {
    let requests = await _get_requests();

    for (request in Array.vals(requests)) {
      await _handle_request(request);
      request_index += 1;
    };
  };

  private func _get_requests() : async [Supersolid.ServiceRequest] {
    await S.poll_requests(Nat64.fromNat(request_index));
  };

  private func _handle_request(r : Supersolid.ServiceRequest) : async () {
    switch (_decode_request_data(r.data)) {
      case (#err(e)) {
        _log_error(r.caller, null, e # " - could not decode:" # r.data, false);
      };
      case (#ok(request)) {
        
        switch (_balance_available(request)) {
          case (false) {
            await _reimburse_eth(r.caller, "Insufficient protocol liquity on destination chain", request);
          };
          case (true) {

            switch (request.destination_chain) {
              case (42161) {
                arb_bal := arb_bal - request.eth_amount;
                await _send_eth(r.caller, request);
              };
              case (8453) {
                base_bal := base_bal - request.eth_amount;
                await _send_eth(r.caller, request);
              };
              case _ {
                await _reimburse_eth(r.caller, "destination chain not recognized", request);
              };
            };
          };
        };
      };
    };
  };

  private func _send_eth(caller : Text, r : T.Request) : async () {
    switch (r.destination_chain) {
      case (42161) {
        let result = await S.send_request(r.destination_chain, r.destination_address, "", Nat64.toNat(r.eth_amount));

        switch (result) {
          case (#Err(e)) {
            _log_error(caller, ?r, "Destination send_request failed", false);
          };
          case (#Ok({})) {
            arb_bal := arb_bal - r.eth_amount;
            _log_swap(caller, r);
          };
        };
        
      };
      case (8453) {
        
        base_bal := base_bal - r.eth_amount;
      };
      case _ {
        await _reimburse_eth(caller, "Destination chain not compatible", r);
      };
    };
  };

  private func _reimburse_eth(caller : Text, reason : Text, request : T.Request ) : async () {
    var destination : Nat64 = arb_id;

    if (request.destination_chain == arb_id) {
      destination := base_id;
    };

    let reimbursement = await S.send_request(destination, caller, "", Nat64.toNat(request.eth_amount));

    switch (reimbursement) {
      case (#Err(e)) {
        _log_error(caller, ?request, reason # "- Reimbursement send_request failed", false);
      };
      case (#Ok({})) {
        _log_error(caller, ?request, reason, true);
      };
    };
  };

  private func _log_swap(caller : Text, request : T.Request) {
    let entry = {
      timestamp = Time.now();
      caller = caller;
      request = request;
      arb_remaining_balance = arb_bal;
      base_remaining_balance = base_bal;
    };
    
    log.put(request_index, #Swap(entry));
  };

  private func _log_error(caller : Text, request : ?T.Request, description : Text, reimbursed : Bool) {
    let entry = {
      timestamp = Time.now();
      caller = caller;
      request = request;
      description = description;
      reimbursed = reimbursed;
      arb_remaining_balance = arb_bal;
      base_remaining_balance = base_bal;
    };
    
    log.put(request_index, #Error(entry));
  };

  private func _update_balances() : async T.BalancesResult {

    switch (Helpers.hex_to_nat64(await S.get_user_balance(arb_id, null, null))) {
      case (#err(e)) { return #err(e) };
      case (#ok(b)) {
        arb_bal := b;
      };
    };

    switch (Helpers.hex_to_nat64(await S.get_user_balance(base_id, null, null))) {
      case (#err(e)) { return #err(e) };
      case (#ok(b)) {
        base_bal := b;
      };
    };

    let balances = {
      arbitrum = arb_bal;
      base = base_bal;
    };
    
    return #ok(balances);
  };

  private func _decode_request_data(h : Hex.Hex) : Result.Result<T.Request, Text> {
    let data = Text.toArray(Text.trimStart(h, #text "0x"));
    var chain : Nat64 = 0;
    var recipient : Text = "";
    var amount : Nat64 = 0;
    
    if (Array.size(data) < 72) {
      return #err("Command HEX data too short.");
    };

    switch (Helpers.hex_to_nat64(Helpers.array_to_text(Array.subArray(data, 0, 16)))) {
      case (#err(e)) { return #err(e)};
      case (#ok(result)) {
        chain := result;
      };
    };

    recipient := "0x" # Helpers.array_to_text(Array.subArray(data, 16, 40));
    
    switch (Helpers.hex_to_nat64(Helpers.array_to_text(Array.subArray(data, 56, 16)))) {
      case (#err(e)) { return #err(e)};
      case (#ok(result)) {
        amount := result;
      };
    };

    let request = {
      destination_chain = chain;
      destination_address = recipient;
      eth_amount = amount;
    };

    return #ok(request);
  };

  //  ----------- Boolean helper functions
    private func _balance_available(r : T.Request) : Bool {
    switch (r.destination_chain) {
      case (42161) {
        
        if (arb_bal > r.eth_amount) {
          return true;
        } else {
          return false;
        };
      };
      case (8453) {
        if (base_bal > r.eth_amount) {
          return true;
        } else {
          return false;
        };
      };
      case _ {
        return false;
      };
    };
  };


  //  ----------- System functions
  system func preupgrade() {
    logEntries := Iter.toArray(log.entries());
  };

  system func postupgrade() {
    logEntries := [];
  };

};