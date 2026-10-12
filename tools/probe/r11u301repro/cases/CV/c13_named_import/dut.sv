// § caConstVarFoldNeedsReducibleInit301
package p;
  function int mk(); return 6; endfunction
  int w = mk();
endpackage
module child (output int o);
  import p::w;
  assign o = w;
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
