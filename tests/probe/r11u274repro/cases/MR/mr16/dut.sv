// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
endpackage
module kid #(parameter pk::c_t P = '0) (input logic clk, output logic [31:0] o);
  always_ff @(posedge clk) o <= P.u.a + P.u.b + P.d;
endmodule
module dut(input logic clk, output logic [31:0] o); kid k0 (.clk(clk), .o(o)); endmodule
