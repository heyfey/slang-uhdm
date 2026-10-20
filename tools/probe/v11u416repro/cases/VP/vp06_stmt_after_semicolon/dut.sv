// § pasteBlankLedStartWritten416
`define ss(OP) \
  a = N``OP; b = 2;

module top;
  localparam int NA = 1, NBB = 2, NCCC = 4, NDDDDD = 8;
  int a, b;
  initial begin
    `ss(A)
    `ss(BB)
    `ss(CCC)
    `ss(DDDDD)
  end
endmodule
