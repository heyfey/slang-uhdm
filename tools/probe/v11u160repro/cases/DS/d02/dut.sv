// § ppMacroBodyLines160
`define ASRT(name, cond) \
`ifndef SYNTHESIS \
  assign name = ~cond; \
`endif \
  assign name = cond; \
  assign w = cond;
module top (input logic a, input logic b, output logic y, output logic w);
  `ASRT(y, a & b)
endmodule
