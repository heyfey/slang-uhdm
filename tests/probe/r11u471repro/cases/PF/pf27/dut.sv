// § procAsgRhsPkgFoldTs471
// always_comb, plain vector parameter
package a;
  parameter logic [3:0] PA = 4'd9;
endpackage
module top(output logic [3:0] y);
  import a::*;
  always_comb y = PA;
endmodule
