export const idlFactory = ({ IDL }) => {
  const Hex = IDL.Text;
  const Request = IDL.Record({
    'destination_address' : IDL.Text,
    'destination_chain' : IDL.Nat64,
    'eth_amount' : IDL.Nat64,
  });
  const Result_1 = IDL.Variant({ 'ok' : Request, 'err' : IDL.Text });
  const Balances = IDL.Record({ 'arbitrum' : IDL.Nat64, 'base' : IDL.Nat64 });
  const BalancesResult = IDL.Variant({ 'ok' : Balances, 'err' : IDL.Text });
  const Result = IDL.Variant({ 'ok' : IDL.Nat64, 'err' : IDL.Text });
  const ServiceRequest = IDL.Record({ 'data' : IDL.Text, 'caller' : IDL.Text });
  const DEMO = IDL.Service({
    'decode_request_data' : IDL.Func([Hex], [Result_1], []),
    'get_balances' : IDL.Func([], [BalancesResult], []),
    'get_request_hex' : IDL.Func([IDL.Nat64, IDL.Text, IDL.Float64], [Hex], []),
    'hex_to_nat64' : IDL.Func([Hex], [Result], []),
    'nat64_to_hex' : IDL.Func([IDL.Nat64], [Hex], []),
    'poll_requests' : IDL.Func([], [IDL.Vec(ServiceRequest)], []),
    'turn_off' : IDL.Func([], [BalancesResult], []),
    'turn_on' : IDL.Func([], [BalancesResult], []),
  });
  return DEMO;
};
export const init = ({ IDL }) => { return []; };
