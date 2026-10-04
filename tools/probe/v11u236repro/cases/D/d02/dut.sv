// § defConnIpsFoldTsOwner236 — indexed part selects in port connections: module localparam base, import-star package names, a member path, an instance array
package pk;
  localparam int W = 4;
  localparam int B = 2;
  typedef struct packed { logic [15:0] q; } a_t;
  typedef struct packed { a_t addr; } r_t;
endpackage
module sub (input logic [3:0] a_i, output logic o);
  assign o = ^a_i;
endmodule
module mid import pk::*; (input logic [15:0] x, input r_t r, output logic o, output logic o2, output logic [1:0] o3);
  localparam int LB = 3;
  sub u_s (.a_i(x[LB +: W]), .o(o));
  sub u_r (.a_i(r.addr.q[B +: W]), .o(o2));
  sub u_a [1:0] (.a_i(x[B +: W]), .o(o3));
endmodule
module top import pk::*; (input logic [15:0] x, input r_t r, output logic o, output logic o2, output logic [1:0] o3);
  mid u_m (.x(x), .r(r), .o(o), .o2(o2), .o3(o3));
endmodule
