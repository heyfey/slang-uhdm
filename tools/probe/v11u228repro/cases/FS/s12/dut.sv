// § pvSizeNoElemDeclines228v § parseViewSizeExprEval228 — fixed-then-queue and fixed-then-dynamic operands beside a fixed one (r11u228's binary exited rc 139 in the parse view; Surelog writes no database)
module dut (output logic [7:0] o1, o2, o3);
  bit [2:0] fq [2][$];
  byte fdy [3][];
  bit [3:0][1:0] bp;
  wire [7:0] w1 = $size(fq);
  wire [7:0] w2 = $size(fdy, 1);
  wire [7:0] w3 = $size(bp);
  assign o1 = w1; assign o2 = w2; assign o3 = w3;
endmodule
