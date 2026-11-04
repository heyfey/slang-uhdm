// § pasteBlankLedStartWritten416
`define bs(OP) \
  if (k&N``OP) begin a = 1; end

module top;
  localparam int NA = 1, NBB = 2, NCCC = 4, NDDDD = 8;
  int k, a;
  initial begin
    `bs(A)
    `bs(BB)
    `bs(CCC)
    `bs(DDDD)
  end
endmodule
