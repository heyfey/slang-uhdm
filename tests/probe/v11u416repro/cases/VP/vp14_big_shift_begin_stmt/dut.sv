// § pasteBlankLedStartWritten416
`define bb(OP) \
  if (N``OP) begin a = b; end

module top;
  localparam int NLONGNAMEXYZW = 1, NLONGERNAMEXYZWVU = 2;
  int a, b;
  initial begin
    `bb(LONGNAMEXYZW)
    `bb(LONGERNAMEXYZWVU)
  end
endmodule
