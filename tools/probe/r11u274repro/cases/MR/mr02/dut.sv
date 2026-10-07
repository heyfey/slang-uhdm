// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
  localparam c_t C = '0;
endpackage
module kid #(parameter pk::c_t P = '0) (input logic clk, output logic [7:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    if (i == 0) begin : h
      always_comb o = P.u.b;
    end
  end
endmodule
module dut(input logic clk, output logic [7:0] o); kid k0 (.clk(clk), .o(o)); endmodule
