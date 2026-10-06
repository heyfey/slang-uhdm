// § selOpFoldReducibleKinds269v
module m #(parameter P = 3) (output wire [15:0] w);
  assign w[7:0] = 8'h1 << P;
  assign w[15:8] = 8'h80 >> P;
endmodule
module top(output wire [15:0] w);
  m u(.w(w));
endmodule
