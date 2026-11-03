// § caAddLeafIntMint477
package a;
  typedef logic [5:0] t;
  parameter t PA = 6'd33;
  parameter t PB = PA;
endpackage
module top(output logic [5:0] z);
  import a::*;
  assign z = (PB + 6'd1) * 2;
endmodule
