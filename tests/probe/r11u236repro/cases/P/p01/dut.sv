// § defConnIpsFoldTsOwner236 — Earlgrey #121109: an indexed part select with package parameter base and width in a port connection
package pk;
  localparam int W = 4;
  localparam int B = 2;
  typedef struct packed { logic [15:0] q; } a_t;
  typedef struct packed { a_t addr; } r_t;
endpackage
module sub import pk::*; (input logic [W-1:0] a_i, output logic o);
  assign o = ^a_i;
endmodule
module mid import pk::*; (input logic [15:0] x, output logic o);
  sub u_s (.a_i(x[B +: W]), .o(o));
endmodule
module top (input logic [15:0] x, output logic o);
  mid u_m (.x(x), .o(o));
endmodule
