// § importCopyTsInstByRole469
// a typedef whose range reads another home parameter
package a;
  parameter int W = 6;
  typedef logic [W-1:0] t;
  parameter t PA = 5;
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
