// § ppMacroBodyLines160
`define USE_B
`define SEL(o, a, b) \
`ifdef USE_B \
  assign o = `INV( \
      b); \
`else \
  assign o = 1'b0; \
`endif
`define INV(z) ~z
module top (input logic a, input logic b, output logic o);
  `SEL(o, a, b)
endmodule
