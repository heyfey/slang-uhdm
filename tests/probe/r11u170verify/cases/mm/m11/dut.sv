// § ppMacroBodyLines160
`define SEL(o, a, b) \
  assign o = a; \
  assign o = `INV( \
      b); \
  assign o = 1'b0;
`define INV(z) ~z
module top (input logic a, input logic b, output logic o);
  `SEL(o, a, b)
endmodule
