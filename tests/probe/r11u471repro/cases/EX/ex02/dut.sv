// § pkgExportItemReImports471
// b re-exports a with export a::*, c imports b
package a;
  parameter int PA = 5;
  parameter int PB = 6;
endpackage
package b;
  import a::*;
  export a::*;
  localparam int LB = PA + PB;
endpackage
package c;
  import b::*;
endpackage
module top;
  logic w;
endmodule
