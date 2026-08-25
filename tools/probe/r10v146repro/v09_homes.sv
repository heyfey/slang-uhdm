// $unit import; homes = interface, program, nested module, instance ARRAY, TWO tops.
package pv9;
  parameter int NW = 4;
  parameter string TAG = "nine";
endpackage
import pv9::*;
interface if_v9;
  logic [NW-1:0] bus;
  modport mp (input bus);
endinterface
program prog_v9;
  int p;
  initial p = NW;
endprogram
module inner_v9 (output logic [NW-1:0] o);
  assign o = NW;
endmodule
module top_v9a;
  logic [NW-1:0] w [0:2];
  inner_v9 ua [0:2] (.o(w));
  if_v9 i0();
endmodule
module top_v9b;
  logic [NW-1:0] v;
  inner_v9 ub (.o(v));
endmodule
