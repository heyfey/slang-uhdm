// § procAsgRhsPkgFoldTs471
// two instances of the reading module
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd9;
  parameter logic [3:0] PB = 4'd5;
  parameter PU = 7;
  typedef enum logic [1:0] {I0, I1, I2} e_t;
  parameter e_t PE = I2;
endpackage
module sub(output logic [3:0] y);
  import a::*;
  always_comb y = PA;
endmodule
module top(output logic [3:0] y1, y2);
  sub u1(y1);
  sub u2(y2);
endmodule
