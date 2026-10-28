// § pkgDupSignalLeftoverNet451
package a;
  int va;
  wire [1:0] na;
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
  import a::*;
  import b::*;
  import c::*;
  int x = PA;
endmodule
