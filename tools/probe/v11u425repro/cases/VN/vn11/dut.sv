// § unszPkgFoldNdaNoTs425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter HX = 'h1F;
  parameter B = 'b101;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
  parameter HU = 'd2_00;
endpackage
module top(output logic [15:0] y);
  import p::*;
  wire [15:0] w = HU;
  wire w1 = H;
  assign y = w + w1;
endmodule
