// § impTdParamCaFoldTs471
// RESIDUE struct-typed parameter (older face)
package a;
  typedef struct packed { logic [1:0] x; logic [1:0] z; } s_t;
  parameter s_t PS = 4'd9;
endpackage
module top(output logic [3:0] y);
  import a::*;
  assign y = PS;
endmodule
