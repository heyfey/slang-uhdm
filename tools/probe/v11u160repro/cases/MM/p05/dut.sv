// § ppMacroBodyLines160
`define ASRT(name, cond) \
  assign name = cond; \
  assign w = cond;
module top (input logic a, input logic b, output logic y);
  wire w;
  `ASRT(y, (a &
            b))
endmodule
