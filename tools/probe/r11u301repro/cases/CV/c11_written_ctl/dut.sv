// § caConstVarFoldNeedsReducibleInit301
module child (input logic c, output int o);
  function int mk(); return 6; endfunction
  int w = mk();
  always @(c) w = 1;
  assign o = w;
endmodule
module dut (input logic c, output int o);
  child u (.c(c), .o(o));
endmodule
