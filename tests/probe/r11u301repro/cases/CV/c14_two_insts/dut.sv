// § caConstVarFoldNeedsReducibleInit301
package p;
  function int mk(); return 6; endfunction
  int w = mk();
endpackage
module child (output int o);
  import p::*;
  assign o = w;
endmodule
module dut (output int o0, o1);
  child u0 (.o(o0));
  child u1 (.o(o1));
endmodule
