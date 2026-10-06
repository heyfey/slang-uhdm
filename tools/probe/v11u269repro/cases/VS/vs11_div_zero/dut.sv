// § selOpFoldReducibleKinds269v
module m(output wire [7:0] w);
  assign w[3:0] = 4'd1 / 4'd0;
  assign w[7:4] = 4'd7 % 4'd2;
endmodule
module top(output wire [7:0] w);
  m u(.w(w));
endmodule
