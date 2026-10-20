// § pasteBlankLedStartWritten416
`define sa(OP) \
  if (k == N``OP) a = 1;

module top;
  localparam int NA = 1, NBB = 2, NCCC = 3, NDDDD = 4;
  int k, a;
  initial begin
    `sa(A)
    `sa(BB)
    `sa(CCC)
    `sa(DDDD)
  end
endmodule
