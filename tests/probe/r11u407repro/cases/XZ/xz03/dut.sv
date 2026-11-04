// § typedParamXzLitSize407
module sub #(parameter int P = 1'bx) (output int o);
  assign o = P;
endmodule
module top(output int o, output int p);
  sub u(o);
  sub #(.P(3)) v(p);
endmodule
