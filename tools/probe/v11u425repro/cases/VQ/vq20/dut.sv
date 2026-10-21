// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter HX = 'h1F;
  parameter B = 'b101;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
program prg(output int y);
  initial y = p::H + p::O;
endprogram
module top(output int y);
  prg u(.y(y));
endmodule
