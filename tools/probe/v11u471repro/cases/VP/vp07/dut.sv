// § procAsgRhsPkgFoldTs471
// procedural continuous assign and a conditional right side
package a;
  parameter logic [3:0] PA = 4'd7;
  parameter logic [3:0] PB = 4'd1;
endpackage
module top(input logic s, output logic [3:0] y, output logic [3:0] z);
  import a::*;
  always_comb z = s ? PA : PB;
  initial assign y = PA;
endmodule
