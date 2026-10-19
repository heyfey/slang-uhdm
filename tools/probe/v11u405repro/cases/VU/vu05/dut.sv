// § unboundedTypedParamTs405
module top #(parameter logic [11:0] q = $) (output int o);
  initial o = $isunbounded(q);
endmodule
