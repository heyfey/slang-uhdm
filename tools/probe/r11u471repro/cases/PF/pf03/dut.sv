// § procAsgRhsPkgFoldTs471
// untyped and enum parameters together (untyped: older int face)
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd9;
  parameter logic [3:0] PB = 4'd5;
  parameter PU = 7;
  typedef enum logic [1:0] {I0, I1, I2} e_t;
  parameter e_t PE = I2;
endpackage
module top(output logic [31:0] y, output logic [1:0] z);
  import a::*;
  always_comb begin y = PU; z = PE; end
endmodule
