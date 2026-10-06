// § selOpFoldReducibleKinds269v
module m #(parameter P = 4'b1111) (output wire [3:0] w);
  assign w[0] = &P;
  assign w[1] = ~^P;
  assign w[3:2] = 2'b0;
endmodule
module top(output wire [3:0] a);
  m u1(.w(a));
endmodule
