// § modImpCopyTdChainHomeTop473
// program reads PB
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
program prg(output logic [3:0] y);
  import b::*;
  initial y = PB;
endprogram
module top(output logic [3:0] y);
  prg p(y);
endmodule
