// § pkgExplicitImpVarReExport453
package a;
  int va;
  class K; int z; endclass
endpackage
package b;
  import a::va;
  import a::K;
  K kk;
endpackage
module top;
  import b::*;
endmodule
