// § impTdParamCaFoldTs471
// $unit import of the typedef parameter, two continuous assignments
package a;
  typedef logic [7:0] b_t;
  parameter b_t PA = 8'h3c;
  parameter b_t PB = 8'd1;
endpackage
import a::*;
module top(output logic [7:0] y, output logic [7:0] z);
  assign y = PA;
  assign z = PB;
endmodule
