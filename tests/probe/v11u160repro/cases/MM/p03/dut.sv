// § ppMacroBodyLines160
`define ASRT(name, cond) \
`ifdef LATE \
  initial $display("x"); \
`endif \
  assign name = cond;
module top (input logic a, input logic b, output logic y);
  `ASRT(y, a & b)
endmodule
`define LATE
