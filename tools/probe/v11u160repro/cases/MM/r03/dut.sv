// § ppMacroBodyLines160
`define OUTER(n, x) \
`ifdef NOPE \
  assign n = 0; \
`elsif NOPE2 \
  assign n = 1; \
`else \
  assign n = x; \
`endif \
  assign w = x;
module top (input logic x, output logic y, output logic w);
  `OUTER(y, (x
    & x))
endmodule
