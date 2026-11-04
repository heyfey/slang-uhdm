// § modImpCopyTdChainHomeTop473
// b exports a::*, module uses t and PB
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  export a::*;
  parameter t PB = 5;
endpackage
module top(output logic [3:0] y);
  import b::*;
  parameter t MP = 3;
  assign y = PB ^ MP;
endmodule
