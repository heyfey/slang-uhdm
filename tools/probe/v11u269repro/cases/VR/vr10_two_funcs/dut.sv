// § retTopRangeOwnPkg269
package up;
  parameter W = 12;
  localparam L = W - 1;
  function logic[L:0] f1(string str);
    $swrite(f1, "%0s", str);
  endfunction
  function logic[W:0] f2(string str);
    $swrite(f2, "%0s", str);
  endfunction
endpackage
package sp;
  import up::*;
  int v;
endpackage
package sp2;
  import up::*;
  int v2;
endpackage
module top(output int o);
  assign o = sp::v + sp2::v2;
endmodule
