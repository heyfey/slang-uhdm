// § hpSelIdxPkgFoldTsOwner236 — Earlgrey #121109: a package parameter in a port connection expression
package pk;
  localparam int W = 4;
  localparam int B = 2;
endpackage
module sub import pk::*; (input logic [W-1:0] a_i, input logic [B-1:0] b_i, output logic o);
  assign o = ^a_i ^ ^b_i;
endmodule
module top import pk::*; (input logic [7:0] x, output logic o);
  sub u_s (.a_i(x[W-1:0]), .b_i(x[W+B-1:W]), .o(o));
endmodule
