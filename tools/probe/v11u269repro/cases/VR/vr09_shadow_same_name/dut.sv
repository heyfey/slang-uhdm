// § retTopRangeOwnPkg269
package op;
  parameter LS = 15;
endpackage
package up;
  parameter LS = 31;
  function logic[op::LS:up::LS] s2b(string str);
    $swrite(s2b, "%0s", str);
  endfunction
endpackage
package sp;
  import up::*;
  import op::*;
  int v;
endpackage
module top(output int o);
  assign o = sp::v;
endmodule
