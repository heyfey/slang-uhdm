// § impUnbasedReadIsLit405
package p;
  localparam a_lp = '0;
  localparam b_lp = '1;
  localparam c_lp = 'x;
endpackage
module top import p::*; (input logic [3:0] i, output logic [3:0] o, output logic [3:0] q, output logic [3:0] r);
  assign o = i + a_lp;
  assign q = i & b_lp;
  assign r = i | c_lp;
endmodule
