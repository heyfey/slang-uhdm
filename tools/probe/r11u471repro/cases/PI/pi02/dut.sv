// § pkgInitImpReadFolds471
// the imported parameter as an operand
package a;
  parameter int PA = 5;
endpackage
package b;
  import a::*;
  localparam int LB = PA + 1;
endpackage
module top;
  logic w;
endmodule
