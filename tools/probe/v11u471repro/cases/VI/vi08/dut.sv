// § pkgInitImpReadFolds471
// imported parameter typed by the home's typedef, read as an operand in the importer
package a;
  typedef logic [5:0] t;
  parameter t PA = 6'd12;
  localparam int LA = 3;
endpackage
package b;
  import a::*;
  localparam int LB = PA + LA;
  localparam logic [5:0] LC = PA;
endpackage
module top(output int y);
  import b::*;
  assign y = LB;
endmodule
