// § defConnIpsFoldTsOwner236 — a literal base, a package width
package pk;
  localparam int W = 4;
  localparam int B = 2;
  localparam int H = 11;
  typedef struct packed { logic [15:0] q; } a_t;
  typedef struct packed { a_t addr; } r_t;
endpackage
module sub (input logic [3:0] a_i, output logic o);
  assign o = ^a_i;
endmodule
module mid import pk::*; (input logic [15:0] x, input r_t r, output logic o);
  localparam int LB = 3;
  sub u_s (.a_i(x[2 +: W]), .o(o));
endmodule
module top import pk::*; (input logic [15:0] x, input r_t r, output logic o);
  mid u_m (.x(x), .r(r), .o(o));
endmodule
