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
module sub(output logic [7:0] y);
  import p::*;
  wire [7:0] w = H;
  wire [7:0] v = O;
  assign y = w ^ v;
endmodule
module top(output logic [7:0] y1, output logic [7:0] y2);
  sub u1(.y(y1));
  sub u2(.y(y2));
endmodule
