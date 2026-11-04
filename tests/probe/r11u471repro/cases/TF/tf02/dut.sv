// § impTdParamCaFoldTs471
// explicit import a::PA
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd9;
endpackage
module top(output logic [3:0] y);
  import a::PA;
  assign y = PA;
endmodule
