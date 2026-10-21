// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter HX = 'h1F;
  parameter B = 'b101;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
module top(output int y, output logic [7:0] y8, output int z, output logic [7:0] z8);
  assign y = p::H;
  assign y8 = p::H;
  assign z = p::O;
  assign z8 = p::O;
endmodule
