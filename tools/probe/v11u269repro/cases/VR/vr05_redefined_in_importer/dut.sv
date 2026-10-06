// § retTopRangeOwnPkg269
package q;
  parameter W = 5;
  function logic [W:0] f(int a);
    return a;
  endfunction
endpackage
package sp;
  import q::f;
  parameter W = 11;
  int v;
endpackage
module top(output logic [5:0] o);
  assign o = sp::W + q::f(1);
endmodule
