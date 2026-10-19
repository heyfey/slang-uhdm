// § impUnbasedReadIsLit405
package p;
  localparam a_lp = '0;
  localparam b_lp = '1;
endpackage
module top (input logic [3:0] i, output logic [3:0] o, output logic [3:0] r);
  assign o = i + p::a_lp;
  assign r = i ^ p::b_lp;
endmodule
