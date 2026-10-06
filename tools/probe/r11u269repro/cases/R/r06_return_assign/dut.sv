// § retTopRangeOwnPkg269 (the return name assigned, not passed to a system task)
package up;
  parameter W = 10;
  parameter LS = W*2-1;
  function logic [LS:0] f(logic [LS:0] a);
    f = a;
    f[0] = 1'b0;
  endfunction
endpackage
package sp;
  import up::*;
  int v;
endpackage
module top(output int o); assign o = sp::v; endmodule
