// § ppOutputFile166 § ppOutputLine166
`include "defs.svh"
module top(input logic [7:0] a, output logic [7:0] y, output logic [7:0] z, output logic [7:0] w);
  function automatic logic [7:0] f(logic [7:0] x, logic [7:0] q); return x + q; endfunction
  assign y = f(`XW,
    a);
  assign z = a;
  assign w = a;
endmodule
