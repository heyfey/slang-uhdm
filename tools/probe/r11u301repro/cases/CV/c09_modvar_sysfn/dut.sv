// § caConstVarFoldNeedsReducibleInit301
module child (output int o);
  int w = $clog2(16);
  assign o = w;
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
