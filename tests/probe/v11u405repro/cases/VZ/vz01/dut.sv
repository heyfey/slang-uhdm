// § impUnbasedReadIsLit405
package p;
  localparam b_lp = '1;
endpackage
module top import p::*; (input logic [3:0] i, output logic [3:0] o);
  always_comb o = i & b_lp;
endmodule
