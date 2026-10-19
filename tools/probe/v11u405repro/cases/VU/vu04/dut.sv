// § unboundedTypedParamTs405
module top #(parameter shortint q = $, parameter byte r = $) (output int o);
  initial o = $isunbounded(q) + $isunbounded(r);
endmodule
