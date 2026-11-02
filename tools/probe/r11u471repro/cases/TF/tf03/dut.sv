// § impTdParamCaFoldTs471
// enum-typed parameter
package a;
  typedef enum logic [1:0] {I0, I1, I2} e_t;
  parameter e_t PE = I1;
endpackage
module top(output logic [1:0] y);
  import a::*;
  assign y = PE;
endmodule
