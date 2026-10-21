// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter HX = 'h1F;
  parameter B = 'b101;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
module top(output int y);
  localparam int L = p::H + 1;
  localparam M = p::O;
  assign y = L + M;
endmodule
