// § genProcFoldDeclTsScopeNamed167 — a typedef-typed parameter (`word_t Z`) folded in a gen-if process
module top #(parameter int W = 6) (input logic clk, output logic [W-1:0] q);
  typedef logic [W-1:0] word_t;
  localparam word_t Z = 6'd9;
  if (W > 1) begin : g
    always_ff @(posedge clk) q <= Z;
  end
endmodule
