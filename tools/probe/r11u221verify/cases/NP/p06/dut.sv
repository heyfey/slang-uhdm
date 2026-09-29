// § ndaPortQueryKeepsStamp221v (with § ndaQueryFoldsNoStamp217v § ndaSysCallNetTs212) — a non-ANSI unpacked input port
module dut (a, o);
  input logic [3:0] a [0:4];
  output logic [7:0] o;
  wire [7:0] w = $left(a);
  assign o = w;
endmodule
