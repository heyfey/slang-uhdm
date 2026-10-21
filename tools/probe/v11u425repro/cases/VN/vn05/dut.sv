// § unszPkgFoldElabForm425
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
  wire [7:0] w = p::H;
  wire [7:0] v = p::O;
  wire [7:0] u = p::B;
  assign y = w ^ v ^ u;
endmodule
