// § caWholeSysCallSharesDefCell428
module m(input [7:0] x, input [7:0] w, output y);
  assign y = $isunknown(x);
endmodule
module top(input [7:0] a, output c);
  m u1(.x(a), .w(a), .y(c));
  m u2(.x(a), .w(a), .y());
endmodule
