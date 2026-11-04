// § ifacePrgOrderedConnMaterializes404v
program prg(input logic c); initial $display(c); endprogram
module top(input i, output y);
  prg p1(w);
  assign w = i;
  assign y = w;
endmodule
