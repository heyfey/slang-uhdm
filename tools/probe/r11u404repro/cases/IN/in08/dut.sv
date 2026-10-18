// § implicitNetDefLastRef404
module top();
  wire [1:0] a;
  sub u1(.i(c), .o(a[0]));
  sub u2(.i(a[1]), .o(c));
  sub u3(e, a[1]);
  assign f = e;
  initial $display("%b %b", c, e);
endmodule
module sub(input i, output o); assign o = i; endmodule
