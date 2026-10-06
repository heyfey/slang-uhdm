// § retTopRangeOwnPkg269 (the range names two parameters)
package up;
  parameter A = 3;
  parameter B = 5;
  function logic [A*B-1:0] f(int x);
    $swrite(f, "%0d", x);
  endfunction
endpackage
package sp;
  import up::*;
  int v;
endpackage
module top(output int o); assign o = sp::v; endmodule
