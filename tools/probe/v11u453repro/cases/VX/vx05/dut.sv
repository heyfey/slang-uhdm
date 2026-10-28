// § pkgExplicitImpParamReExport453
package a;
  parameter int PA = 1;
  parameter int PA2 = 3;
endpackage
package b;
  import a::PA;
  import a::PA2;
endpackage
package c;
  import b::*;
  import a::*;
endpackage
module top;
  import c::*;
endmodule
