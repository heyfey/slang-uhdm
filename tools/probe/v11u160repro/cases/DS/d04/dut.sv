// § ppMacroBodyLines160
`define ASRT(name, cond) \
`ifdef SYNTHESIS \
  assign name = cond; \
`else \
  assign name = ~cond; \
  assign name = ~cond; \
`endif \
  assign w = cond;
module top (input logic a, input logic b, output logic y, output logic w);
  `ASRT(y, a & b)
endmodule
