// § modImpCopyTdChainHomeTop473
// CONTROL an enum typedef of the home
package a;
  typedef enum logic [1:0] {X, Y, Z} t;
endpackage
package b;
  import a::*;
  parameter t PB = Y;
endpackage
module top(output logic [1:0] y);
  import b::*;
  assign y = PB;
endmodule
