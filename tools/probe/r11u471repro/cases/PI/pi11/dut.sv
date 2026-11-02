// § pkgInitImpReadFolds471
// untyped imported parameter as an operand
package a;
  parameter PA = 12;
endpackage
package b;
  import a::*;
  localparam LB = PA - 2;
endpackage
module top;
  logic w;
endmodule
