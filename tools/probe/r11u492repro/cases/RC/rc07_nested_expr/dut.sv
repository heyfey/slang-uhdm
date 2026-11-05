// the bare call inside a return expression
package zp;
  function int zf (int x);
    return x;
  endfunction
endpackage
package ap;
  import zp::*;
  function int af (int a);
    return zf(a) + 1;
  endfunction
endpackage
module m;
  int r;
  initial r = ap::af(1);
endmodule
