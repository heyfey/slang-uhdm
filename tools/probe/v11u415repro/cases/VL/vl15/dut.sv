// § pkgLetCallFuncCall415
package pex;
  let sum2(x, y) = x + y;
  class C;
    logic [3:0] a, b;
    function logic [4:0] g();
      return sum2(a, b);
    endfunction
  endclass
endpackage
module top(output logic [4:0] o);
  import pex::*;
  C h;
  initial begin h = new; o = h.g(); end
endmodule
