// § genProcFoldDeclTsScopeNamed167 — an int parameter folded in a gen-if process (an int typespec: the law abstains)
module top #(parameter int Z = 5) (input logic clk, output int q);
  if (1) begin : g
    always_ff @(posedge clk) q <= Z;
  end
endmodule
