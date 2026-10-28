// § modCopyImportsFirst453
package a;
  int va;
endpackage
package b;
  int vb;
  import a::*;
endpackage
module top;
  import a::*;
  import b::*;
  int vt;
endmodule
