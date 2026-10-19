// § impUnbasedReadIsLit405
package p;
  localparam none_lp = '0;
  localparam swap_lp = none_lp + 1;
endpackage
module top import p::*; (input logic [3:0] i, output logic [3:0] o);
  assign o = i + none_lp;
endmodule
