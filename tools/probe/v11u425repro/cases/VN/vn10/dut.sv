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
module top(output logic [40:0] y, output logic [7:0] z);
  import p::*;
  wire [40:0] w = BIG;
  wire [7:0] v = Z;
  assign y = w;
  assign z = v;
endmodule
