// § selOpFoldReducibleKinds269v
module m #(parameter P = 4'd5) (output wire [7:0] w);
  assign w[0 +: 4] = P & 4'h7;
  assign w[7 -: 4] = {2{P[1:0]}};
endmodule
module top(output wire [7:0] w);
  m u(.w(w));
endmodule
