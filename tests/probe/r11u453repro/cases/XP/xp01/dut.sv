// § pkgExplicitImpParamReExport453
package a;
  parameter int PA = 1;
  parameter int PA2 = 5;
endpackage
package b;
  import a::PA;
  int vb;
endpackage
package c;
  import b::*;
  int vc;
endpackage
module top;
endmodule
