// § unszPkgFoldNdaNoTs425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter S = 'sd100;
  parameter HX = 'h1F;
  parameter B = 'b101;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
  parameter HU = 'd2_00;
endpackage
module top(output logic signed [7:0] y);
  import p::*;
  wire signed [7:0] w = S;
  assign y = w;
endmodule
