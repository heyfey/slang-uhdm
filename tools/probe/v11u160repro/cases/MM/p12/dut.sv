// § ppMacroBodyLines160
`define MULTI(a, b) \
  assign a = b;
module top (input logic x, output logic y, output logic z);
  assign z = x; `MULTI(y, x)
endmodule
