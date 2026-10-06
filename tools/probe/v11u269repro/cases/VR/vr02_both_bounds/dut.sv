// § retTopRangeOwnPkg269
package p;
  parameter W = 9;
endpackage
package q;
  parameter W = 2;
  function logic [p::W:q::W] f(int a);
    return a;
  endfunction
endpackage
package sp;
  import q::*;
  import p::*;
  int v;
endpackage
module top(output logic [9:0] o);
  assign o = q::f(1);
endmodule
