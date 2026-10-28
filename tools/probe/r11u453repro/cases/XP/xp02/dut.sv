// § pkgExplicitImpParamReExport453
package a;
  parameter int PA = 1;
  parameter int PA2 = 5;
endpackage
package b;
  import a::PA;
  parameter int PB = 2;
endpackage
module top;
  import b::*;
  int x;
  assign x = PB;
endmodule
