// § caConstVarFoldNeedsReducibleInit301
package p;
  function int mk(); return 6; endfunction
  int w = mk();
endpackage
module dut (output int o);
  import p::*;
  assign o = w;
endmodule
