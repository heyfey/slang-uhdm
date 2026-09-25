// § ppMacroBodyLines160
`define WRAP(stmt) \
  always_comb begin \
    stmt \
  end
`define ML(o, x) o = x | \
                     1'b0;
module top (input logic a, output logic o);
  `WRAP(`ML(o, a))
endmodule
