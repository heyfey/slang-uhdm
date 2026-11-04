// § impTdParamCaFoldTs471
// two instances of a module reading an imported typedef parameter
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd9;
endpackage
module sub(output logic [3:0] y);
  import a::*;
  assign y = PA;
endmodule
module top(output logic [3:0] y1, output logic [3:0] y2);
  sub u1(y1);
  sub u2(y2);
endmodule
