// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = 24'h010203) (input logic clk, output logic [7:0] o);
  logic [7:0] m [8];
  always_ff @(posedge clk) begin
    m[P.u.a[2:0]]++;
    o <= m[P.u.b[2:0] + 1];
  end
endmodule
module dut(input logic clk, output logic [7:0] o); kid k0 (.clk(clk), .o(o)); endmodule
