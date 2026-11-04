// § pkgExplicitImpParamReExport453
package a;
  localparam int LA = 7;
  parameter int PA = 1;
endpackage
package b;
  import a::LA;
  import a::*;
  parameter int PB = 2;
endpackage
module top;
  import b::*;
endmodule
