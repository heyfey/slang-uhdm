// § pkgDupSignalLeftoverNet451
package a;
  int va;
  logic [3:0] wa;
  parameter int PA = 1;
endpackage
package b;
  import a::*;
  int vb;
  parameter PB = 2;
endpackage
package c;
  import a::*;
  int vc;
endpackage
package d;
  import b::*;
  import c::*;
  import a::*;
  int vd;
endpackage
module top;
endmodule
