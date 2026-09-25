// § ppMacroBodyLines160
`include "defs.svh"
module top (input logic a, input logic b, output logic y, output logic z);
  assign z = a; `ASRT(y, a & b)
endmodule
