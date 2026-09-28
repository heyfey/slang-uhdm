// § ndaRangeQueryFold216 — the queried net declared in an included header, the initializer in the including file
module dut (output logic [3:0] o);
`include "decl.svh"
  wire [3:0] w = $low(v);
  assign o = w;
endmodule
