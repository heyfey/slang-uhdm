// § ndaPortQueryKeepsStamp221v (with § ndaQueryFoldsNoStamp217v § ndaSysCallNetTs212) — an unpacked OUTPUT port queried by another net
module dut (output logic [3:0] b [3], output logic [7:0] o);
  wire [7:0] w = $high(b);
  assign o = w;
endmodule
