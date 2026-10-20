// § pasteBlankLedStartWritten416
`define ca(OP) \
  if (f(N``OP)) begin

module top;
  localparam int NA = 1, NBB = 2, NCCC = 4;
  function automatic int f(int v); return v; endfunction
  int a;
  initial begin
    `ca(A) a = 1; end
    `ca(BB) a = 2; end
    `ca(CCC) a = 3; end
  end
endmodule
