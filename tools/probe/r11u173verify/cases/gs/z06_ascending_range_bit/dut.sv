// § genProcFoldDeclTsScopeNamed167 — a bit parameter with an ascending range folded in a gen-if always_comb
module top #(parameter int W = 5, parameter bit [0:W-1] Z = 5'b10110) (output bit [0:W-1] q);
  if (1) begin : g
    always_comb q = Z;
  end
endmodule
