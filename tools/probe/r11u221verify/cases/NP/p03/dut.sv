// § ndaPortQueryKeepsStamp221v (with § ndaQueryFoldsNoStamp217v § ndaSysCallNetTs212) — a two-dimensional unpacked input port [2][3] (the outer dimension queried)
module dut (input logic [3:0] a [2][3], output logic [7:0] o);
  wire [7:0] w1 = $low(a);
  wire [7:0] w2 = $right(a);
  assign o = w1 + w2;
endmodule
