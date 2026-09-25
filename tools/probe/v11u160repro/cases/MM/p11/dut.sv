// § ppMacroBodyLines160
`define ASRT(name, cond) \
`ifndef SYNTHESIS \
  initial $display("x"); \
  initial $display("x2"); \
`endif \
  assign name = cond;
module top (input logic a, input logic b, output logic y);
  `ASRT(y, a & b)
endmodule
