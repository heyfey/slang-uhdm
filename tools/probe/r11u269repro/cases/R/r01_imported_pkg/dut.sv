// § retTopRangeOwnPkg269
package up;
  parameter W = 120;
  parameter N = 120;
  parameter LS = W*N*8-1;
  function logic[LS:0] s2b(string str);
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
