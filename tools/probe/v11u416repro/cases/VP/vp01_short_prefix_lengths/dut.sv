// § pasteBlankLedStartWritten416
`define ob(OP) \
  if (!(k&X``OP)) begin

module top;
  localparam int XA = 1, XBB = 2, XCCC = 3, XDDDD = 4, XEEEEE = 5, XFFFFFF = 6;
  int k, a;
  initial begin
    `ob(A) a = 1; end
    `ob(BB) a = 2; end
    `ob(CCC) a = 3; end
    `ob(DDDD) a = 4; end
    `ob(EEEEE) a = 5; end
    `ob(FFFFFF) a = 6; end
  end
endmodule
