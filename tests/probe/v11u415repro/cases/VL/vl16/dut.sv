// § pkgLetCallFuncCall415
package pex;
  let sum2(x, y) = x + y;
endpackage
package q;
  import pex::*;
  logic [3:0] a, b;
  function automatic logic [4:0] g();
    return sum2(a, b);
  endfunction
endpackage
module top(output logic [4:0] o);
  import q::*;
  assign o = g();
endmodule
