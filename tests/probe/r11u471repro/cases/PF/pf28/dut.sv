// § procAsgRhsPkgFoldTs471
// always_comb, enum parameter
package a;
  typedef enum logic [1:0] {I0, I1, I2} e_t;
  parameter e_t PE = I1;
endpackage
module top(output logic [1:0] y);
  import a::*;
  always_comb y = PE;
endmodule
