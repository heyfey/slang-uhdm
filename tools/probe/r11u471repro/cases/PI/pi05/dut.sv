// § pkgInitImpReadFolds471
// a parameter, not a localparam
package a;
  parameter int PA = 5;
endpackage
package b;
  import a::*;
  parameter int LB = PA + 1;
endpackage
module top;
  logic w;
endmodule
