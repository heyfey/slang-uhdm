// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter HX = 'h1F;
  parameter B = 'b101;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
module top(input logic [7:0] a, output logic y, output logic z, output int w);
  assign y = a == p::HX;
  assign z = a == p::B;
  assign w = p::Z + p::BIG;
endmodule
