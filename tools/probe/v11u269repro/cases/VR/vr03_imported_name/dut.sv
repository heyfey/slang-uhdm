// § retTopRangeOwnPkg269
package p;
  parameter W = 7;
endpackage
package q;
  import p::W;
  parameter N = 3;
  function logic [W:0] f(int a);
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
