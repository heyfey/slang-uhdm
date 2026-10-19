// residue (no law landed): a gate terminal index naming a parameter folds to UINT size 32 with a select-named ref_typespec; see README
module top;
  wire [3:0] a, y;
  genvar i;
  for (i = 0; i < 2; i = i + 1) begin : g
    localparam int K = i + 1;
    buf b1 (y[K], a[K]);
  end
endmodule
