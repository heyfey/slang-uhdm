// § retTopRangeOwnPkg269 (control: a class method returning a parameter-ranged vector)
package up;
  parameter W = 10;
  class c;
    function logic [W-1:0] f(string s);
      $swrite(f, "%0s", s);
    endfunction
  endclass
endpackage
package sp;
  import up::*;
  int v;
endpackage
module top(output int o); assign o = sp::v; endmodule
