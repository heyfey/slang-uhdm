// § caConstVarFoldNeedsReducibleInit301
module child (output int o);
  function int mk(); return 6; endfunction
  int w = mk();
  assign o = w;
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
