// § unboundedTypedParamTs405
module sub #(parameter int n = $) (output int o);
  assign o = $isunbounded(n);
endmodule
module top(output int o);
  sub #(.n(3)) u(o);
endmodule
