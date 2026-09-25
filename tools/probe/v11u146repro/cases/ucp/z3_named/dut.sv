// § ucpIfaceInstElabShape146
module f({a, b}, d);
  input a, b; output d;
  assign d = a;
endmodule
module top(input x, output y);
  f u(x, y);
endmodule
