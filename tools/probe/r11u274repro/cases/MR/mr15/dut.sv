// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam c_t C = '{u: '{a: 1, b: 2}, d: 3};
endpackage
module kid #(parameter pk::c_t P = pk::C) (input logic clk, output logic [31:0] o);
  task automatic t(output logic [31:0] x); x = P.u.a; endtask
  always_ff @(posedge clk) begin
    logic [31:0] y;
    t(y);
    o <= y + P.d;
  end
endmodule
module dut(input logic clk, output logic [31:0] o); kid k0 (.clk(clk), .o(o)); endmodule
