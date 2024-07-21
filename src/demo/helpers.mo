import Array        "mo:base/Array";
import Blob         "mo:base/Blob";
import Char         "mo:base/Char";
import Nat8         "mo:base/Nat8";
import Nat64        "mo:base/Nat64";
import Text         "mo:base/Text";
import Result       "mo:base/Result";

import Binary       "lib/Binary";
import Hex          "lib/Hex";

module {

  public func nat64_to_hex(n : Nat64) : Hex.Hex {
    Hex.encode(nat64_to_bytes(n));
  };

  public func hex_to_nat64(t : Hex.Hex) : Result.Result<Nat64, Text> {
    let h = Text.trimStart(t, #text "0x");

    switch (Hex.decode(h)) {
      case (#err(e)) { return #err(e) };
      case (#ok(result)) { 
        if (Array.size(result) < 8) {
          let a = Array.append<Nat8>(Array.freeze<Nat8>(Array.init<Nat8>(8 - Array.size<Nat8>(result), 0 : Nat8)), result);
          return #ok(Binary.BigEndian.toNat64(a));
        } else {
          return #ok(Binary.BigEndian.toNat64(result));
        };  
      }
    };
  };

  public func text_to_hex(t : Text) : Hex.Hex {
    Hex.encode(Blob.toArray(Text.encodeUtf8(t)));
  };

  public func hex_to_text(t : Hex.Hex) : Result.Result<?Text, Text> {
    let h = Text.trimStart(t, #text "0x");

    switch (Hex.decode(h)) {
      case (#err(e)) { return #err(e) };
      case (#ok(result)) { 
        return #ok(Text.decodeUtf8(Blob.fromArray(result)));
      };
    };
  };

  public func array_to_text(a : [Char]) : Text {
    Array.foldLeft<Char, Text>(a, "", func(x, c) = x # Char.toText(c));
  };

  // Converts a Nat64 into an array of bytes
  func nat64_to_bytes(n: Nat64) : [Nat8] {
    func byte(n: Nat64) : Nat8 {
      Nat8.fromNat(Nat64.toNat(n & 0xff))
    };
    [byte(n >> 56), byte(n >> 48), byte(n >> 40), byte(n >> 32), byte(n >> 24), byte(n >> 16), byte(n >> 8), byte(n)]
  };

}