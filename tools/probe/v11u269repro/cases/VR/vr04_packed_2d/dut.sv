// § retTopRangeOwnPkg269
package q;
  parameter W = 4;
  parameter N = 2;
  function logic [N-1:0][W-1:0] f(int a);
    return a;
  endfunction
endpackage
package sp;
  import q::*;
  int v;
endpackage
module top(output logic [7:0] o);
  assign o = q::f(1);
endmodule
