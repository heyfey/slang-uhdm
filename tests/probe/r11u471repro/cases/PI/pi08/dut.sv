// § pkgInitImpReadFolds471
// explicit import a::PA, two operands
package a;
  parameter int PA = 5;
  parameter int PB = 3;
endpackage
package b;
  import a::PA;
  import a::PB;
  localparam int LB = PA * PB - 1;
endpackage
module top;
  logic w;
endmodule
