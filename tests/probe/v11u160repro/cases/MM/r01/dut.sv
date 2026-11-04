// § ppMacroBodyLines160
`define STR(x) `"x`"
`define CHK(name, cond) \
  assign name = cond; \
  initial $display(`STR(name), " ok");
module top (input logic a, output logic y);
  `CHK(y, a)
endmodule
