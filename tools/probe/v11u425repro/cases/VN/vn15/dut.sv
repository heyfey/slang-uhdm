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
module top(output logic [7:0] y);
  import p::*;
  wire [7:0] w = HX;
  wire [7:0] v = B;
  wire [31:0] u = H;
  assign y = w ^ v ^ u[7:0];
endmodule
