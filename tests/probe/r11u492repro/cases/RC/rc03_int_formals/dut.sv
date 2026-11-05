// builtin int formals
package zp;
  function int zf (int x, int y);
    return x + y;
  endfunction
endpackage
package ap;
  import zp::*;
  function int af (int a, int b);
    return zf(a, b);
  endfunction
endpackage
module m;
  int r;
  initial r = ap::af(1, 2);
endmodule
