// § pasteBlankLedStartWritten416
`define pc(OP) \
  if ((k & N``OP) != 0) a = k + 1;

module top;
  localparam int NA = 1, NBB = 2, NCCC = 4, NDDDD = 8;
  int k, a;
  initial begin
    `pc(A)
    `pc(BB)
    `pc(CCC)
    `pc(DDDD)
  end
endmodule
