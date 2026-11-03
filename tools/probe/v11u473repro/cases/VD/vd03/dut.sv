// § modImpCopyTdChainHomeTop473
// CONTROL enum typedef
package a;
  typedef enum logic [1:0] {X0, X1, X2} t;
endpackage
package b;
  import a::*;
  parameter t PB = X2;
endpackage
module top(output logic [1:0] y);
  import b::*;
  assign y = PB;
endmodule
