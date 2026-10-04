// § defConnIpsFoldTsOwner236 — an instance array
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
  logic [1:0] t; sub u_a [1:0] (.a_i(x[B +: W]), .o(t)); assign o = ^t;
endmodule
module top import pk::*; (input logic [15:0] x, input r_t r, output logic o);
  mid u_m (.x(x), .r(r), .o(o));
endmodule
