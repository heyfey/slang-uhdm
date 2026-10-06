// § retTopRangeOwnPkg269
package q;
  parameter W = 5;
  localparam L = W*2;
  function automatic logic [L:0] f(input logic [W:0] a);
    logic [W:0] t;
    t = a;
    return {t, t};
  endfunction
endpackage
package sp;
  import q::*;
  int v;
endpackage
package sp2;
  import q::*;
  int u;
endpackage
module top(output logic [11:0] o);
  assign o = q::f(6'h3);
endmodule
