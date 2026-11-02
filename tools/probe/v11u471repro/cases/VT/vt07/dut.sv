// § impTdParamCaFoldTs471
// interface reading a typedef-typed imported parameter
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd4;
endpackage
interface ifc;
  import a::*;
  logic [3:0] v;
  assign v = PA;
endinterface
module top(output logic [3:0] y);
  ifc u();
  assign y = u.v;
endmodule
