// § pkgDupSignalLeftoverNet451
package a;
  int va;
  parameter int PA = 1;
endpackage
package b;
  import a::*;
  int vb;
endpackage
package c;
  import a::*;
  import b::*;
  int vc;
endpackage
module top;
  import c::*;
  int x = vc;
endmodule
