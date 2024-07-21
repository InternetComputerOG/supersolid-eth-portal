module {
  public type HttpOutcallError = {
    #IcError : { code : RejectionCode; message : Text };
    #InvalidHttpJsonRpcResponse : {
      status : Nat16;
      body : Text;
      parsingError : ?Text;
    };
  };
  public type JsonRpcError = { code : Int64; message : Text };
  public type LedgerKey = { #HexAddress : Text; #IcPrincipal : Principal };
  public type ProviderError = {
    #TooFewCycles : { expected : Nat; received : Nat };
    #MissingRequiredProvider;
    #ProviderNotFound;
    #NoPermission;
  };
  public type RejectionCode = {
    #NoError;
    #CanisterError;
    #SysTransient;
    #DestinationInvalid;
    #Unknown;
    #SysFatal;
    #CanisterReject;
  };
  public type Result = { #Ok; #Err : RouterError };
  public type RouterError = {
    #Locked;
    #DecodingError : Text;
    #Unknown : Text;
    #RpcResponseError : RpcError;
    #NonExistentValue;
    #InsufficientFunds;
  };
  public type RpcError = {
    #JsonRpcError : JsonRpcError;
    #ProviderError : ProviderError;
    #ValidationError : ValidationError;
    #HttpOutcallError : HttpOutcallError;
  };
  public type ServiceRequest = { data : Text; caller : Text };
  public type ValidationError = {
    #CredentialPathNotAllowed;
    #HostNotAllowed : Text;
    #CredentialHeaderNotAllowed;
    #UrlParseError : Text;
    #Custom : Text;
    #InvalidHex : Text;
  };
  public type Self = actor {
    add_request : shared (Text, Text, Principal) -> async ();
    balance : shared query Nat64 -> async Text;
    get_chain_ledger : shared query Nat64 -> async [
        (LedgerKey, [(?Text, Text)])
      ];
    get_user_balance : shared query (Nat64, ?Text, ?LedgerKey) -> async Nat64;
    poll_others_requests : shared query Principal -> async [ServiceRequest];
    poll_requests : shared query Nat64 -> async [ServiceRequest];
    public_key : shared query () -> async Text;
    send_request : shared (Nat64, Text, Text, Nat) -> async Result;
    start : shared [(Text, Nat64)] -> async ();
  }
}