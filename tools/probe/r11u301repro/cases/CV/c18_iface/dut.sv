// § caConstVarFoldNeedsReducibleInit301
package p;
  function int mk(); return 6; endfunction
  int w = mk();
endpackage
interface ifc;
  import p::*;
  int o;
  assign o = w;
endinterface
module dut (output int o);
  ifc u ();
  assign o = u.o;
endmodule
