// § diamondImportListsPerPath451
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
endpackage
package d;
  import c::*;
  int vd;
endpackage
module top;
  import d::*;
  initial vd = 1;
endmodule
