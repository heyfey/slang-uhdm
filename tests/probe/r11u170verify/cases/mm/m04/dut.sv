// § ppMacroBodyLines160
`include "defs.svh"
module top (input logic a, input logic b, output logic x, output logic y);
  `DRV(x, a)
  wire t; `DRV(y, b)
endmodule
