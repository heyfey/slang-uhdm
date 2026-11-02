// § pkgInitImpReadFolds471
// a package localparam initialized by a wildcard-imported parameter
package a;
  parameter int PA = 5;
endpackage
package b;
  import a::*;
  localparam int LB = PA;
endpackage
module top;
  logic w;
endmodule
