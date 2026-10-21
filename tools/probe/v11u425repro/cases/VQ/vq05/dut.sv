// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter HX = 'h1F;
  parameter B = 'b101;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
module sub(input logic [7:0] i, output logic [7:0] o);
  assign o = i;
endmodule
module top(output logic [7:0] y, output logic [7:0] z);
  sub u1(.i(p::H), .o(y));
  sub u2(.i(p::O), .o(z));
endmodule
