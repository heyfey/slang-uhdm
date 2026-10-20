// § pkgLetCallFuncCall415
package pex;
  let inc(x) = x + 1;
  let dbl(y) = inc(y) * 2;
endpackage
module top(input logic [3:0] s, output logic [5:0] o);
  import pex::*;
  assign o = dbl(s);
endmodule
