// § modCopyImportsFirst453
package a;
  int va;
endpackage
package a2;
  int va2;
endpackage
package b;
  int vb;
  import a::*;
  int vb2;
  import a2::va2;
endpackage
module top;
  import b::*;
endmodule
