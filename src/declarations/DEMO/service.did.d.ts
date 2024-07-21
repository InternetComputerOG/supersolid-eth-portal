import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Balances { 'arbitrum' : bigint, 'base' : bigint }
export type BalancesResult = { 'ok' : Balances } |
  { 'err' : string };
export interface DEMO {
  'change_index' : ActorMethod<[bigint], bigint>,
  'check_index' : ActorMethod<[], bigint>,
  'decode_request_data' : ActorMethod<[Hex], Result_1>,
  'get_balances' : ActorMethod<[], BalancesResult>,
  'get_logs' : ActorMethod<[], Array<[bigint, Entry]>>,
  'get_request_hex' : ActorMethod<[bigint, string, number], Hex>,
  'hex_to_nat64' : ActorMethod<[Hex], Result>,
  'nat64_to_hex' : ActorMethod<[bigint], Hex>,
  'poll_requests' : ActorMethod<[], Array<ServiceRequest>>,
  'process_requests' : ActorMethod<[], undefined>,
  'turn_off' : ActorMethod<[], BalancesResult>,
}
export type Entry = { 'Error' : ErrorEntry } |
  { 'Swap' : SwapEntry };
export interface ErrorEntry {
  'request' : [] | [Request],
  'description' : string,
  'base_remaining_balance' : bigint,
  'timestamp' : Time,
  'caller' : string,
  'arb_remaining_balance' : bigint,
  'reimbursed' : boolean,
}
export type Hex = string;
export interface Request {
  'destination_address' : string,
  'destination_chain' : bigint,
  'eth_amount' : bigint,
}
export type Result = { 'ok' : bigint } |
  { 'err' : string };
export type Result_1 = { 'ok' : Request } |
  { 'err' : string };
export interface ServiceRequest { 'data' : string, 'caller' : string }
export interface SwapEntry {
  'request' : Request,
  'base_remaining_balance' : bigint,
  'timestamp' : Time,
  'caller' : string,
  'arb_remaining_balance' : bigint,
}
export type Time = bigint;
export interface _SERVICE extends DEMO {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
