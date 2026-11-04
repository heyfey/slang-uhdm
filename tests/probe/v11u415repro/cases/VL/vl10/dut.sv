// § pkgLetCallFuncCall415
package pex;
  let sum2(x, y) = x + y;
endpackage
module top(output logic [4:0] o);
  import pex::*;
  function automatic logic [4:0] f();
    logic [3:0] p, q;
    p = 1; q = 2;
    return sum2(p, q);
  endfunction
  assign o = f();
endmodule
