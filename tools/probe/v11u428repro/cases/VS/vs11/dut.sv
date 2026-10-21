// § caWholeSysCallSharesDefCell428
module m(input [7:0] x, output y);
  assign y = $onehot0(x);
endmodule
module top(input [7:0] a, output c);
  m u1(.x(a), .y(c));
endmodule
