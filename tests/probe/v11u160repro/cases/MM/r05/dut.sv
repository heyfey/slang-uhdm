// § ppMacroBodyLines160
`define M3(n, x) \
  always_comb begin \
    n = x; \
  end
module top (input logic x, output logic y, output logic z);
  always_comb z = x; `M3(y, x)
endmodule
