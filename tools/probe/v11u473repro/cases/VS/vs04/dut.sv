// § modImpCopyTdChainHomeTop473
// CONTROL interface own parameter of an imported typedef
package a;
  typedef logic [3:0] t;
  parameter t PA = 2;
endpackage
interface ifc;
  import a::*;
  parameter t IP = 6;
  logic [3:0] v;
  assign v = IP;
endinterface
module top(output logic [3:0] y);
  ifc u();
  assign y = u.v;
endmodule
