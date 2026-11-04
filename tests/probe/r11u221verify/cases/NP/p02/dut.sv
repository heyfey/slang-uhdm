// § ndaPortQueryKeepsStamp221v (with § ndaQueryFoldsNoStamp217v § ndaSysCallNetTs212) — an ascending unpacked input port [0:4], two declarators in one net declaration
module dut (input logic [3:0] a [0:4], output logic [7:0] o);
  wire [7:0] w1 = $left(a), w2 = $high(a);
  assign o = w1 + w2;
endmodule
