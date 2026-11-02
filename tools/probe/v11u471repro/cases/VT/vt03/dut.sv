// § impTdParamCaFoldTs471
// typedef-typed parameter in a generate block's continuous assignment
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd9;
endpackage
module top(output logic [3:0] y);
  import a::*;
  if (1) begin : g
    assign y = PA;
  end
endmodule
