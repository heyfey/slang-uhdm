// § genvarIdxFoldRerender14 ARM pc4 — an UNMODELLED operator on the index
// spine (`%`, `**`, a ternary, a call).  `srlgRedCt14` ABSTAINS and the cell
// must be BYTE-IDENTICAL between the two binaries.
module leaf (input logic p);
  wire w;
  assign w = p;
endmodule
module top (input logic [63:0] arr);
  genvar i;
  for (i = 0; i < 2; ++i) begin : g
    leaf ua (.p (arr[i % 3]));
    leaf ub (.p (arr[2 ** i]));
    leaf uc (.p (arr[(i == 0) ? 4 : 5]));
  end
endmodule
