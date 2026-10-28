// § pkgExplicitImpVarReExport453
package a;
  int va;
  int vu [2];
endpackage
package b;
  import a::*;
  import a::va;
  import a::vu;
endpackage
module top;
  import b::*;
endmodule
