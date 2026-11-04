// § ndaPortQueryKeepsStamp221v (with § ndaQueryFoldsNoStamp217v § ndaSysCallNetTs212) — an unpacked port of scalar elements
module dut (input logic a [3], output logic [7:0] o);
  wire [7:0] w = $high(a);
  assign o = w;
endmodule
