// § pasteBlankLedStartWritten416
`define tp(OP) \
  if (A``OP == B``OP) begin

module top;
  localparam int AX = 1, BX = 1, AYYY = 2, BYYY = 2, AZZZZZ = 3, BZZZZZ = 3;
  int a;
  initial begin
    `tp(X) a = 1; end
    `tp(YYY) a = 2; end
    `tp(ZZZZZ) a = 3; end
  end
endmodule
