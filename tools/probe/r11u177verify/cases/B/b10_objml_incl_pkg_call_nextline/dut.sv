// § ppOutputFile166 § ppOutputLine166
`include "defs.svh"
package p;
  function automatic int f(int x, int y); return x + y; endfunction
  localparam int K = f(`XW,
    5);
endpackage
module top(input logic [7:0] a, output logic [7:0] y, output logic [7:0] z, output logic [7:0] w);
  assign y = a + p::K;
  assign z = a;
  assign w = a;
endmodule
