// § impUnbasedLitKept405
package p;
  localparam a_lp = '0;
  parameter b_p = '1;
endpackage
module top (input logic [3:0] i, output logic [3:0] o);
  import p::*;
  assign o = (i == a_lp) ? b_p : i;
endmodule
