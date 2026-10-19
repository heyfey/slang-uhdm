// § unboundedTypedParamTs405
module m #(parameter int q = $) (output int o);
  assign o = $isunbounded(q) ? 1 : q;
endmodule
module top(output int o, output int p);
  m u(o);
  m #(.q(7)) v(p);
endmodule
