// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
module top(input logic [7:0] a, output logic [15:0] y, output logic [15:0] z);
  always_comb y = a + p::Z;
  always_comb z = a + p::O;
endmodule
