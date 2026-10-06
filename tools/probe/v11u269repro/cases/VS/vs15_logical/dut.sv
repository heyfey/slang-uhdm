// § selOpFoldReducibleKinds269v
module m #(parameter P = 1) (output wire [3:0] w);
  assign w[0] = P && 1'b1;
  assign w[1] = !P;
  assign w[2] = P < 2;
  assign w[3] = 1'b1 ~^ 1'b0;
endmodule
module top(output wire [3:0] w);
  m u(.w(w));
endmodule
