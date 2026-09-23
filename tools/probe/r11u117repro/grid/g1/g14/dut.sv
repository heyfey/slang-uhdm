// WIDE (>64b) struct, qualified member select in module localparam
package q2;
  typedef struct packed { logic [31:0] a; logic [31:0] b; logic [11:0] v; } impl_t;
  localparam impl_t IMPL = '{ a: 32'h1, b: 32'h2, v: {4'h1, 8'h23} };
endpackage
module top(output logic [11:0] o);
  localparam logic [11:0] V = q2::IMPL.v;
  assign o = V;
endmodule
