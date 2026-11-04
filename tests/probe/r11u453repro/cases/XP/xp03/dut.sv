// § pkgExplicitImpParamReExport453
package a;
  parameter int PA = 1;
  int va;
endpackage
package b;
  import a::PA;
  import a::va;
  parameter int PB = 2;
endpackage
package c;
  import a::*;
  import b::*;
endpackage
module top;
  import c::*;
endmodule
