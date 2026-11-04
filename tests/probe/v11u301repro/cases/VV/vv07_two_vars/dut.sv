// § caConstVarFoldNeedsReducibleInit301
module child (output int o, output int q);
  function automatic int mk(); return 4; endfunction
  int w = mk();
  int k = 5;
  assign o = w;
  assign q = k;
endmodule
module dut (output int o, output int q);
  child u (.o(o), .q(q));
endmodule
