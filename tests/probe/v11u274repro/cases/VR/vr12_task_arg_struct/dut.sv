// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = 24'h010203) (input logic clk, output logic [7:0] o);
  task automatic t(input pk::in_t x, output logic [7:0] y); y = x.a; endtask
  always_ff @(posedge clk) begin
    logic [7:0] z;
    t(P.u, z);
    o <= z + P.u.b;
  end
endmodule
module dut(input logic clk, output logic [7:0] o); kid k0 (.clk(clk), .o(o)); endmodule
