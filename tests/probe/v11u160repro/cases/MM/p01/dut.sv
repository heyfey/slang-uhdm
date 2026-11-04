// § ppMacroBodyLines160
`define ASRT(name, cond) \
`ifdef FOO_UNDEF \
  initial $display("x"); \
`else \
  assign name = cond; \
`endif
module top (input logic a, input logic b, output logic y);
  `ASRT(y, a & b)
endmodule
