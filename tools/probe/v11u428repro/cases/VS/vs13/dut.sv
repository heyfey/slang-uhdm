// § caWholeSysCallSharesDefCell428
module m #(parameter P = 8'h0f) (input [7:0] x, output [3:0] y, output [3:0] z);
  assign y = $countones(x);
  assign z = $countones(P);
endmodule
module top(input [7:0] a, output [3:0] c, d);
  m #(.P(8'hff)) u1(.x(a), .y(c), .z(d));
endmodule
