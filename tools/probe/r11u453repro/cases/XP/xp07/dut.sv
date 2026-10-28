// § pkgExplicitImpParamReExport453
package a;
  parameter int PA = 1;
endpackage
package b;
  parameter int PB = 2;
  import a::*;
endpackage
package c;
  import b::*;
endpackage
module top;
endmodule
