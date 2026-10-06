// § retTopRangeOwnPkg269
package op;
  parameter W = 7;
endpackage
package up;
  import op::*;
  parameter N = 3;
  function logic[W*N:0] s2b(string str);
    $swrite(s2b, "%0s", str);
  endfunction
endpackage
package sp;
  import up::*;
  int v;
endpackage
module top(output int o);
  assign o = sp::v;
endmodule
