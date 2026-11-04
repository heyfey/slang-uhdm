// § modImpCopyTdChainHomeTop473
// CONTROL module own parameter of an imported typedef
package a;
  typedef logic [3:0] t;
  parameter t PA = 2;
endpackage
module top(output logic [3:0] y);
  import a::*;
  parameter t MP = 3;
  assign y = MP;
endmodule
