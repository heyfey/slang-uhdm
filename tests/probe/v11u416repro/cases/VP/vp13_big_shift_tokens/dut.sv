// § pasteBlankLedStartWritten416
`define bt(OP) \
  if (N``OP) a = b;

module top;
  localparam int NLONGNAMEXYZW = 1, NX = 2;
  int a, b;
  initial begin
    `bt(LONGNAMEXYZW)
    `bt(X)
  end
endmodule
