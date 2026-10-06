// § selOpFoldReducibleKinds269v
module m #(parameter P = 4'd3) (output wire [7:0] w);
  assign w[3:0] = P + 4'd1;
  assign w[7:4] = P ^ 4'hF;
endmodule
module top(output wire [7:0] a, b);
  m u1(.w(a));
  m #(.P(4'd9)) u2(.w(b));
endmodule
