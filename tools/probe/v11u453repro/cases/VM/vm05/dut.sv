// § modCopyImportsFirst453
package a;
  int va;
endpackage
package b;
  int vb;
  import a::*;
endpackage
package c;
  int vc;
  import b::*;
endpackage
module top;
  import c::*;
endmodule
