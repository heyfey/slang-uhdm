// § unboundedTypedParamTs405
module top #(parameter longint q = $) (output int o);
  initial o = $isunbounded(q);
endmodule
