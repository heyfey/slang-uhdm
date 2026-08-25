// An INTERFACE with its own parameter shadowing the $unit import, referenced
// in the interface body and through a modport.
package pv27;
  parameter int BW = 32;
endpackage
import pv27::*;
interface if_v27 #(parameter int BW = 3) ();
  logic [BW-1:0] d;
  function automatic int fw(); return BW; endfunction
  modport mp (input d, import fw);
endinterface
module top_v27;
  if_v27 #(.BW(5)) i0();
  if_v27           i1();
  int z;
  initial z = BW;
endmodule
