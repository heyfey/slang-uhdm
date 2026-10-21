// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter HX = 'h1F;
  parameter B = 'b101;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
module sub #(parameter int W = 1) (output int y);
  assign y = W;
endmodule
module top(output int y, output int z);
  sub #(.W(p::H)) u1(.y(y));
  sub #(.W(p::O + 1)) u2(.y(z));
endmodule
