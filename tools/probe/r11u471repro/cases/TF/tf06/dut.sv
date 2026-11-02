// § impTdParamCaFoldTs471
// RESIDUE int typedef (older fullname face, not reached)
package a;
  typedef int t;
  parameter t PA = 9;
endpackage
module top(output logic [31:0] y);
  import a::*;
  assign y = PA;
endmodule
