// § ppMacroBodyLines160
`define STR(x) `"x`"
`define ASGN(n) \
  initial $display(`STR(n)); \
  assign n = 1'b1;
module top (output logic y);
  `ASGN(y)
endmodule
