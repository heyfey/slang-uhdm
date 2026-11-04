// § pasteBlankLedStartWritten416
`define lb(OP) \
  case (k) \
    K``OP: begin a = 1; end \
  endcase

module top;
  localparam int KA = 1, KBB = 2, KCCC = 3, KDDDD = 4;
  int k, a;
  initial begin
    `lb(A)
    `lb(BB)
    `lb(CCC)
    `lb(DDDD)
  end
endmodule
