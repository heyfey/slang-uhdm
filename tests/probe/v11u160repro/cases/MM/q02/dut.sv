// § ppMacroBodyLines160
`define ASRT(name, cond) \
`ifdef NOPE // a comment \
  initial $display("x"); \
`endif // done \
  assign name = cond;
module top (input logic a, input logic b, output logic y);
  `ASRT(y, a & b)
endmodule
