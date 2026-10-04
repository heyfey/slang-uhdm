// § defConnIpsFoldTsOwner236 — Earlgrey #121109: indexed part selects with a module localparam in a port connection
package pk;
  localparam int W = 4;
  localparam int B = 2;
endpackage
module sub import pk::*; (input logic [W-1:0] a_i, output logic o);
  assign o = ^a_i;
endmodule
module mid import pk::*; (input logic [15:0] x, output logic o);
  localparam int L = 3;
  sub u_s (.a_i(x[L +: W]), .o(o));
endmodule
module top (input logic [15:0] x, output logic o);
  mid u_m (.x(x), .o(o));
endmodule
