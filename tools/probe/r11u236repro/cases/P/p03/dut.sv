// § defConnIpsFoldTsOwner236 — Earlgrey #121109: indexed part selects in a continuous assignment and a port connection, top level
package pk;
  localparam int W = 4;
  localparam int B = 2;
  typedef struct packed { logic [15:0] q; } a_t;
  typedef struct packed { a_t addr; } r_t;
endpackage
module sub import pk::*; (input logic [W-1:0] a_i, output logic [W-1:0] o);
  assign o = a_i;
endmodule
module top import pk::*; (input logic [15:0] x, output logic [W-1:0] o, output logic [W-1:0] p);
  assign p = x[B +: W];
  sub u_s (.a_i(x[W -: W]), .o(o));
endmodule
