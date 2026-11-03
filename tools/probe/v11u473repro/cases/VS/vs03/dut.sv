// § modImpCopyTdChainHomeTop473
// module own parameter of a typedef re-exported by c
package a;
  typedef logic [3:0] t;
  parameter t PA = 2;
endpackage
package c;
  import a::*;
  export a::*;
  parameter t PC = 4;
endpackage
module top(output logic [3:0] y);
  import c::*;
  parameter t MP = 3;
  assign y = MP;
endmodule
