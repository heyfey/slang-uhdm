// § caConstVarFoldNeedsReducibleInit301
function int mk(); return 6; endfunction
int w = mk();
module child (output int o);
  assign o = w;
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
