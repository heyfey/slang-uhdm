// § modCopyImportsFirst453
package a;
  int va;
endpackage
package b;
  wire wb;
  import a::*;
endpackage
interface ifc;
  import b::*;
endinterface
module top;
  ifc u();
endmodule
