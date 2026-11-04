// § ppOutputLine166
`define USE_B
`define SEL(y, a, b) \
`ifdef USE_A \
  assign y = a; \
`else \
  assign y = \
    b; \
`endif
module top(input logic a, input logic b, output logic y);
  `SEL(y, a, b)
endmodule
