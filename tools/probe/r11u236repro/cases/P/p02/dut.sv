// § defConnIpsFoldTsOwner236 — Earlgrey #119021: an indexed part select ending a member path in a port connection
package pk;
  localparam int W = 4;
  localparam int B = 2;
  typedef struct packed { logic [15:0] q; } a_t;
  typedef struct packed { a_t addr; } r_t;
endpackage
module sub import pk::*; (input logic [W-1:0] a_i, output logic o);
  assign o = ^a_i;
endmodule
module mid import pk::*; (input r_t r, output logic o);
  localparam int L = 3;
  sub u_s (.a_i(r.addr.q[L +: W]), .o(o));
endmodule
module top (input pk::r_t r, output logic o);
  mid u_m (.r(r), .o(o));
endmodule
