// § impUnbasedReadIsLit405
package p;
  localparam a_lp = '0;
  localparam c_lp = 'x;
endpackage
module top import p::*; (input logic [3:0] i, output logic [3:0] o, output logic [3:0] r, output logic q);
  assign o = a_lp;
  assign r = c_lp;
  assign q = (i == a_lp);
endmodule
