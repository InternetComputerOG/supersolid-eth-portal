import Bool         "mo:base/Bool";
import Nat64        "mo:base/Nat64";
import Text         "mo:base/Text";
import Time         "mo:base/Time";
import Result       "mo:base/Result";

module {
  public type BalancesResult = Result.Result<Balances, Text>;

  public type Balances = {
    arbitrum : Nat64;
    base : Nat64;
  };

  public type Request = {
    destination_chain : Nat64;
    destination_address : Text;
    eth_amount : Nat64;
  };

  public type Entry = {
    #Error : ErrorEntry;
    #Swap : SwapEntry;
  };

  public type ErrorEntry = {
    timestamp : Time.Time;
    caller : Text;
    request : ?Request;
    description : Text;
    reimbursed : Bool;
    arb_remaining_balance : Nat64;
    base_remaining_balance : Nat64;
  };

  public type SwapEntry = {
    timestamp : Time.Time;
    caller : Text;
    request : Request;
    arb_remaining_balance : Nat64;
    base_remaining_balance : Nat64;
  };
  
  //  ----------- State
  
  //  ----------- Functions
  
}