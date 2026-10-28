// § pkgExplicitImpParamReExport453
package a;
  localparam int LA = 7;
  parameter int PA = 1;
endpackage
package b;
  parameter int PB = 2;
  import a::LA;
endpackage
package c;
  import b::*;
endpackage
module top;
endmodule
