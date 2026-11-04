// § pkgExplicitImpVarReExport453
package a;
  int va = 5;
  const int vc = 3;
endpackage
package b;
  import a::va;
  import a::vc;
endpackage
module top;
  import b::*;
  import a::va;
endmodule
