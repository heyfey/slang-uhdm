// § modImpCopyTdChainHomeTop473
// nested instance two levels, child reads PB in var init
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module leaf(output logic [3:0] y);
  import b::*;
  logic [3:0] w = PB;
  assign y = w;
endmodule
module mid(output logic [3:0] y); leaf l(y); endmodule
module top(output logic [3:0] y); mid m(y); endmodule
