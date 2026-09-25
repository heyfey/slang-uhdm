// § ppMacroBodyLines160
`define GONE
`undef GONE
`define ASRT(name, cond) \
`ifdef GONE \
  initial $display("x"); \
`endif \
  assign name = cond;
module top (input logic a, input logic b, output logic y);
  `ASRT(y, a & b)
endmodule
