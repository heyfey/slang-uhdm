// § retTopRangeOwnPkg269 (two packages import the home)
package up;
  parameter W = 120;
  parameter LS = W*8-1;
  function logic [LS:0] s2b(string str);
    $swrite(s2b, "%0s", str);
  endfunction
endpackage
package sp;
  import up::*;
  int v;
endpackage
package tp;
  import up::*;
  int w;
endpackage
module top(output int o); assign o = sp::v + tp::w; endmodule
