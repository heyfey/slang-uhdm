// § impTdParamCaFoldTs471
// CONTROL qualified read through an importer (not reached)
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd9;
endpackage
package b;
  import a::*;
endpackage
module top(output logic [3:0] y);
  import b::*;
  assign y = a::PA;
endmodule
