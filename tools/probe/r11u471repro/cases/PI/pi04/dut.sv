// § pkgInitImpReadFolds471
// a module reads the importing package's localparam (head moves later to the older module-copy face)
package a;
  parameter int PA = 5;
endpackage
package b;
  import a::*;
  localparam int LB = PA + 1;
endpackage
module top;
  import b::*;
  logic [31:0] q = LB;
  logic w;
endmodule
