// § ppMacroBodyLines160
`define BAR
`define ASRT(name, cond) \
`ifdef BAR \
  assign name = cond; \
`else \
  initial $display("x"); \
  initial $display("y"); \
`endif \
  assign w = cond;
module top (input logic a, input logic b, output logic y);
  wire w;
  `ASRT(y, a & b)
endmodule
