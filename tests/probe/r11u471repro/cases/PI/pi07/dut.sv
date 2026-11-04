// § pkgInitImpReadFolds471
// CONTROL qualified read a::PA keeps the cross-package reference (not reached)
package a;
  parameter int PA = 5;
endpackage
package b;
  import a::*;
  localparam int LB = a::PA + 1;
endpackage
module top;
  logic w;
endmodule
