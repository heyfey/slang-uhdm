// § ndaPortQueryKeepsStamp221v (with § ndaQueryFoldsNoStamp217v § ndaSysCallNetTs212) — $high/$low/$left/$right of an unpacked input port [5] in four net-declaration initializers
module dut (input logic [3:0] a [5], output logic [7:0] o);
  wire [7:0] w1 = $high(a);
  wire [7:0] w2 = $low(a);
  wire [7:0] w3 = $left(a);
  wire [7:0] w4 = $right(a);
  assign o = w1 + w2 + w3 + w4;
endmodule
