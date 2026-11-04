// § procAsgRhsPkgFoldTs471
// if / else branches
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd9;
  parameter logic [3:0] PB = 4'd5;
  parameter PU = 7;
  typedef enum logic [1:0] {I0, I1, I2} e_t;
  parameter e_t PE = I2;
endpackage
module top(input logic c, output logic [3:0] y);
  import a::*;
  always_comb if (c) y = PA; else y = PB;
endmodule
