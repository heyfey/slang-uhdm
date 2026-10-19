// § typedParamXzLitSize407
module sub #(parameter int P = 1'bx) (output int o);
  assign o = P;
endmodule
module top(output int o);
  defparam u.P = 4'b10x0;
  sub u(o);
endmodule
