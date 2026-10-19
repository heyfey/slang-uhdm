// § typedParamXzLitSize407
module sub #(parameter int P = 1'bx) (output int o);
  assign o = P;
endmodule
module top(output int o, output int p);
  sub #(.P(2'b10)) u(o);
  sub #(.P(3'b1x1)) v(p);
endmodule
