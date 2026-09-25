// § ppMacroBodyLines160
`define ASRT(name, cond) \
`ifdef A1 \
`ifdef A2 \
  initial $display("x"); \
`endif \
  initial $display("z"); \
`elsif A3 \
  initial $display("q"); \
`endif \
  assign name = cond;
`define A3
module top (input logic a, input logic b, output logic y);
  `ASRT(y, a & b)
endmodule
