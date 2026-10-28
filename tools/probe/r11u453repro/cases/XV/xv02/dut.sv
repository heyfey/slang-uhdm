// § pkgExplicitImpVarReExport453
package a;
  int va;
endpackage
package b;
  import a::va;
  int vb;
endpackage
package c;
  import a::*;
  import b::*;
endpackage
module top;
  import c::*;
endmodule
