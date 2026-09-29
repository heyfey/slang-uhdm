// § ndaPortQueryKeepsStamp221v (with § ndaQueryFoldsNoStamp217v § ndaSysCallNetTs212) — controls: a local unpacked variable (golden folds), a packed port (§ ndaRangeQueryFold216 folds), $size of the unpacked port (§ ndaSizeQueryFold216 folds), a generate-scope net
module dut (input logic [3:0] a [5], input logic [5:2] p, output logic [7:0] o, output logic [7:0] o2, output logic [7:0] o3);
  logic [3:0] v [5];
  wire [7:0] wv = $left(v);
  wire [7:0] wp = $left(p);
  wire [7:0] ws = $size(a);
  for (genvar i = 0; i < 1; i++) begin : g
    wire [7:0] wg = $high(a);
    assign o3 = wg;
  end
  assign o = wv + ws;
  assign o2 = wp;
endmodule
