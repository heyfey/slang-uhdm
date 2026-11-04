// § retTopRangeOwnPkg269 (a localparam bound)
package up;
  localparam int W = 16;
  function logic [W-1:0] f(string s);
    $swrite(f, "%0s", s);
  endfunction
endpackage
package sp;
  import up::*;
  int v;
endpackage
module top(output int o); assign o = sp::v; endmodule
