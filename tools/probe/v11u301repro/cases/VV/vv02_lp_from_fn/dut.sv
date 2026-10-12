// § caConstVarFoldNeedsReducibleInit301
module child (output int o);
  function automatic int mk(); return 4; endfunction
  localparam int LP = mk();
  int w = LP;
  assign o = w;
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
