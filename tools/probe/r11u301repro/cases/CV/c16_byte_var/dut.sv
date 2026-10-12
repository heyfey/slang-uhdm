// § caConstVarFoldNeedsReducibleInit301
package p;
  function byte mk(); return 6; endfunction
  byte w = mk();
endpackage
module child (output byte o);
  import p::*;
  assign o = w;
endmodule
module dut (output byte o);
  child u (.o(o));
endmodule
