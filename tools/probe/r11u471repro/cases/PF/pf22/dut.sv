// § procAsgRhsPkgFoldTs471
// program process (the reference names the program definition)
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd9;
  parameter logic [3:0] PB = 4'd5;
  parameter PU = 7;
  typedef enum logic [1:0] {I0, I1, I2} e_t;
  parameter e_t PE = I2;
endpackage
program prg(output logic [3:0] y);
  import a::*;
  initial y = PA;
endprogram
module top(output logic [3:0] y);
  prg p(y);
endmodule
