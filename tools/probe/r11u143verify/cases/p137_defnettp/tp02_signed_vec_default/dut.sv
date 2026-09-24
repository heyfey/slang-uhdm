// § defNetTypeParamDefault137
// case tp02: a type parameter defaulting to a signed bit vector, overridden with logic [3:0]
module sub #(parameter type T = bit signed [3:0]) ();
  T x;
endmodule
module top(); sub #(.T(logic [3:0])) u(); sub v(); endmodule
