// § caConstVarFoldNeedsReducibleInit301
module child (output int o);
  int w = 3 + 4;
  assign o = w;
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
