// § caConstVarFoldNeedsReducibleInit301
module child #(parameter int K = 3) (output int o);
  int w = K * 2;
  assign o = w;
endmodule
module dut (output int o);
  child #(.K(5)) u (.o(o));
endmodule
