// § parseViewSizeExprEval228 — the call written by a macro, and a macro holding the operand
`define SZ(x) $size(x)
`define OP bp
module dut (output logic [7:0] o1, o2);
  bit [3:0][1:0] bp;
  wire [7:0] w1 = `SZ(bp);
  wire [7:0] w2 = $size(`OP);
  assign o1 = w1; assign o2 = w2;
endmodule
