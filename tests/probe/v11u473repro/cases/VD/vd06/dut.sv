// § modImpCopyTdChainHomeTop473
// $unit import of b plus module import of a
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
import b::*;
module top(output logic [3:0] y);
  import a::*;
  t w = PB;
  assign y = w;
endmodule
