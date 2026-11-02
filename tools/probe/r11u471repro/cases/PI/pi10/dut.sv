// § pkgInitImpReadFolds471
// a chain: c reads b's localparam that reads a's parameter
package a;
  parameter int PA = 4;
endpackage
package b;
  import a::*;
  localparam int LB = PA + 2;
endpackage
package c;
  import b::*;
  localparam int LC = LB * 2;
endpackage
module top;
  logic w;
endmodule
