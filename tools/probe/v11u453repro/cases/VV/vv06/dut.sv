// § pkgExplicitImpVarReExport453
package a;
  int va;
endpackage
package b;
  import a::va;
  function automatic int g(); return 2; endfunction
endpackage
program pr;
  import b::*;
endprogram
module top;
endmodule
