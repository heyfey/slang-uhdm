// § modCopyImportsFirst453
package a;
  int va;
endpackage
package b;
  int vb;
  import a::*;
  int vb2;
endpackage
module top;
  import b::*;
endmodule
