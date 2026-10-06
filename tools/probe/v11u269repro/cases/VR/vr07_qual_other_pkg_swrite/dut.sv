// § retTopRangeOwnPkg269
package op;
  parameter W = 7;
endpackage
package up;
  parameter W = 120;
  function logic[op::W:0] s2b(string str);
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
