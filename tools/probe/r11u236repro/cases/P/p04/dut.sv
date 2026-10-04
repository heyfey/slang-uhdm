// § defConnIpsFoldTsOwner236 — Earlgrey #121109: package parameters in port connection expressions of several shapes
package pk;
  localparam int W = 4;
  localparam int B = 2;
endpackage
module sub import pk::*; (input logic [W-1:0] a_i, input logic b_i, input logic [W-1:0] c_i, input int d_i, input logic [W-1:0] e_i, output logic o);
  assign o = ^a_i ^ b_i ^ ^c_i ^ d_i[0] ^ ^e_i;
endmodule
module mid import pk::*; (input logic [15:0] x, output logic o);
  sub u_s (.a_i(x[W-1:0]), .b_i(x[B]), .c_i(x[B +: W] + W), .d_i(B), .e_i({x[B], x[W-2:0]}), .o(o));
endmodule
module top (input logic [15:0] x, output logic o);
  mid u_m (.x(x), .o(o));
endmodule
