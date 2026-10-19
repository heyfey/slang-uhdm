// residue (no law landed): a gate terminal index naming a parameter folds to UINT size 32 with a select-named ref_typespec; see README
module top;
  wire [3:0] a, y;
  localparam int K = 1;
  buf b1 (y[K], a[0]);
  tran t1 (y[2], a[2]);
endmodule
