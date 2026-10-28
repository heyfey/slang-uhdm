// § pkgExplicitImpVarReExport453
package a;
  int va;
endpackage
package b;
  import a::va;
endpackage
module sub(input logic c);
  import b::*;
endmodule
module top;
  logic c;
  sub u(.c(c));
endmodule
