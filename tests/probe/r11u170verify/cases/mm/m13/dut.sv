// § ppMacroBodyLines160
`define USE_B
`define SEL(o, a, b) \
`ifdef USE_A \
  assign o = a; \
`endif \
  assign o = `INV( \
      b);
`define INV(z) ~z
module top (input logic a, input logic b, output logic o);
  `SEL(o, a, b)
endmodule
