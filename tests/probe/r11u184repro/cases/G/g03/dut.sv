// § genScopeTrailSelNameLate184: a macro-born trailing member select in a generate-scope process, and a class handle's member in a generate block
`define RD(v, n) v.f[n]
typedef struct packed { logic [7:0] f; } s_t;
module top #(parameter bit P = 1) (input logic clk, input s_t s, input logic [2:0] i, output logic y);
  if (P) begin : ga
    always_ff @(posedge clk) y <= `RD(s, i);
  end
endmodule
