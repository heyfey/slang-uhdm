// § pkgDupSignalLeftoverNet451
package a;
  int va;
endpackage
package b;
  import a::*;
  int vb;
endpackage
package c;
  import b::*;
  import a::*;
  import b::*;
  int vc;
endpackage
package d;
  import c::*;
  int vd;
endpackage
module top;
  import d::*;
endmodule
