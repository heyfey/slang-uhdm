// § ndaPortQueryKeepsStamp221v (with § ndaQueryFoldsNoStamp217v § ndaSysCallNetTs212) — a child's unpacked port queried in its body, the child instantiated twice
module sub (input logic [3:0] a [4], output logic [7:0] o);
  wire [7:0] w = $low(a), w2 = $right(a);
  assign o = w + w2;
endmodule
module dut (input logic [3:0] x [4], output logic [7:0] o1, output logic [7:0] o2);
  sub u1 (.a(x), .o(o1));
  sub u2 (.a(x), .o(o2));
endmodule
