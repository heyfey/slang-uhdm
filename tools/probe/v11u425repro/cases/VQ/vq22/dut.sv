// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
module top(input logic [7:0] a, output logic [40:0] y);
  always_comb y = a + p::BIG;
endmodule
