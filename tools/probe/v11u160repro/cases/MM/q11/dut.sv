// § ppMacroBodyLines160
`define ASGN(n, v) \
  assign n = v; \
  assign w = v[0];
module top (input logic a, input logic b, output logic [1:0] y, output logic w);
  `ASGN(y, {a,
            b})
endmodule
