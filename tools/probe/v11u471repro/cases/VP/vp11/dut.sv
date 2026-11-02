// § procAsgRhsPkgFoldTs471
// generate-for module instances whose process reads an imported parameter
package a;
  parameter logic [3:0] PA = 4'd2;
endpackage
module sub(output logic [3:0] o);
  import a::*;
  always_comb o = PA;
endmodule
module top(output logic [3:0] y [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    sub s(.o(y[i]));
  end
endmodule
