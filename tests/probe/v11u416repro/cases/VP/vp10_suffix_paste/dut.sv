// § pasteBlankLedStartWritten416
`define sp(OP) \
  if (!(k&OP``_N)) begin

module top;
  localparam int A_N = 1, BB_N = 2, CCC_N = 4, DDDD_N = 8;
  int k, a;
  initial begin
    `sp(A) a = 1; end
    `sp(BB) a = 2; end
    `sp(CCC) a = 3; end
    `sp(DDDD) a = 4; end
  end
endmodule
