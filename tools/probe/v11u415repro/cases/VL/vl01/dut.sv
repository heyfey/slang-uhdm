// § pkgLetCallFuncCall415
package pex;
  logic [3:0] a, b;
  let sum2(x, y) = x + y;
  function automatic logic [4:0] g();
    return sum2(a, b);
  endfunction
endpackage
module top(output logic [4:0] o);
  import pex::*;
  assign o = g();
endmodule
