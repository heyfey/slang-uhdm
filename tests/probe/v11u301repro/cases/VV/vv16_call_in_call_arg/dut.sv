// § caConstVarFoldNeedsReducibleInit301
module child (output int o);
  function automatic int mk(int a); return a * 3; endfunction
  int w = mk(mk(1));
  assign o = w;
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
