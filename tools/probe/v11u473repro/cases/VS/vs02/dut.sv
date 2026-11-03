// § modImpCopyTdChainHomeTop473
// CONTROL module own parameter, b also imported, var init
package a;
  typedef logic [3:0] t;
  parameter t PA = 2;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top(output logic [3:0] y);
  import a::*;
  import b::*;
  parameter t MP = 3;
  logic [3:0] w = MP;
  assign y = w;
endmodule
