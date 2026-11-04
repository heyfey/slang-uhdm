// § caConstVarFoldNeedsReducibleInit301
module dut (output int o);
  function automatic int mk(); return 7; endfunction
  int w = mk();
  assign o = w;
endmodule
