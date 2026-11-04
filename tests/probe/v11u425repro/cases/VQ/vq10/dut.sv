// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter HX = 'h1F;
  parameter B = 'b101;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
module top(input logic [31:0] a, output logic y, output logic [3:0] z);
  assign y = a[p::O];
  assign z = a[p::O -: 4];
endmodule
