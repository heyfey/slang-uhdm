// § pkgLetCallFuncCall415
package pex;
  logic [3:0] a, b;
  let sum2(x, y) = x + y;
  function automatic logic [4:0] g();
    return sum2(a, b);
  endfunction
endpackage
module top(input logic [3:0] c, d, output logic [4:0] o, p);
  import pex::*;
  assign o = g();
  assign p = sum2(c, d);
endmodule
