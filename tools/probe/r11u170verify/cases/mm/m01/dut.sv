// § ppMacroBodyLines160
`define CHK(c) \
  if (!(c)) begin \
`ifdef NEVER_DEFINED \
    $display("never"); \
`else \
    $display("line %0d", `__LINE__); \
`endif \
    o = `ONE_LINE(c); \
  end
`define ONE_LINE(x) (x) ^ 1'b1
module top (input logic a, output logic o);
  always_comb begin
    o = 1'b0;
    `CHK(a)
  end
endmodule
