// § tpTypedVarInitNameSpan275 — an int type parameter with an initializer
module dut #(parameter type T = int) (output int o);
  T x = 5;
  assign o = x;
endmodule
