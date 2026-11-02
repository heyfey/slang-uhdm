// § impTdParamCaFoldTs471
// typedef of a typedef, signed, wider output (sign extension downstream)
package a;
  typedef logic signed [3:0] s4_t;
  typedef s4_t s4b_t;
  parameter s4b_t PS = -4'sd3;
endpackage
module top(output logic signed [7:0] y);
  import a::*;
  assign y = PS;
endmodule
