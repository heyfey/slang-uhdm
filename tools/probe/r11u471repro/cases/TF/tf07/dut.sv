// § impTdParamCaFoldTs471
// CONTROL qualified a::PA (not reached)
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd9;
endpackage
module top(output logic [3:0] y);
  assign y = a::PA;
endmodule
