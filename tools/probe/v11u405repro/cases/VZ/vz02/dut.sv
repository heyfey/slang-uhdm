// § impUnbasedReadIsLit405
package p;
  localparam b_lp = '1;
  localparam z_lp = 'z;
endpackage
module top (input logic [3:0] i, output logic [3:0] o, output logic [3:0] q);
  assign o = i & p::b_lp;
  assign q = i ^ p::z_lp;
endmodule
