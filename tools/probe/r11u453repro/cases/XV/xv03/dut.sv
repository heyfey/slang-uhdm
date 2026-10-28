// § pkgExplicitImpVarReExport453
package a;
  int va;
  int vz;
endpackage
package c;
  import a::va;
  int vc;
endpackage
module top;
  import c::*;
endmodule
