// § unboundedTypedParamTs405
module top(output int o);
  localparam integer r = $;
  assign o = $isunbounded(r);
endmodule
