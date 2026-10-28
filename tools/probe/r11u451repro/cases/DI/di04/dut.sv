// § pkgDupSignalLeftoverNet451
package a;
  int va;
  int va2;
  parameter int PA = 1;
  parameter int PA2 = 5;
endpackage
package b;
  import a::va;
  import a::PA;
  int vb;
endpackage
package c;
  import a::*;
  import b::*;
  int vc;
endpackage
module top;
endmodule
