// § pkgDupSignalLeftoverNet451
package a;
  int va;
  parameter int PA = 1;
  localparam LA = 2;
endpackage
package b;
  import a::*;
  int vb;
  parameter PB = 3;
endpackage
package c;
  import a::*;
  import b::*;
  int vc;
endpackage
module top;
endmodule
