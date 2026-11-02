// § pkgExportItemReImports471
// CONTROL: export *::* holds no import item (not reached)
package a;
  parameter int PA = 5;
endpackage
package b;
  import a::*;
  export *::*;
  localparam int LB = PA;
endpackage
package c;
  import b::*;
endpackage
module top;
  logic w;
endmodule
