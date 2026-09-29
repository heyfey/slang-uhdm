// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — an interface body and a program body with fixed-then-queue and plain fixed operands
interface bus;
  bit [3:0][1:0] x;
  int qq [2][$];
  wire [7:0] w1 = $size(x);
  wire [7:0] w2 = $size(qq, 1);
endinterface
program prg;
  bit [2:0][1:0] y;
  wire [7:0] w3 = $size(y);
endprogram
module dut (output logic [7:0] o1, o2);
  bus b ();
  prg p ();
  assign o1 = b.w1; assign o2 = b.w2;
endmodule
