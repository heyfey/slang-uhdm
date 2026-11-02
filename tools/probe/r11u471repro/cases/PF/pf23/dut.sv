// § procAsgRhsPkgFoldTs471
// array element left sides
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd9;
  parameter logic [3:0] PB = 4'd5;
  parameter PU = 7;
  typedef enum logic [1:0] {I0, I1, I2} e_t;
  parameter e_t PE = I2;
endpackage
module top(output logic [3:0] y);
  import a::*;
  logic [3:0] arr [2];
  always_comb begin arr[0] = PA; arr[1] = PB; y = arr[0]; end
endmodule
