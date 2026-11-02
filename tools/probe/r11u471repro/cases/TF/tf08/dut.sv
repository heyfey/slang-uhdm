// § impTdParamCaFoldTs471
// CONTROL plain vector parameter (the direct arm, byte-identical)
package a;
  parameter logic [3:0] PA = 4'd9;
endpackage
module top(output logic [3:0] y);
  import a::*;
  assign y = PA;
endmodule
