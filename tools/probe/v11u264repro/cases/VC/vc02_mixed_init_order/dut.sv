// § ctorBidLhsCloneCopy264
package bp;
  class c;
    int r;
    extern function new(int k);
  endclass
  function c::new(int k);
    int a = k;
    int b;
    int d = 2, e;
    b = a + d;
    e = b;
    r = e;
  endfunction
endpackage
package up;
  import bp::*;
  function automatic int mk(); c o = new(4); return o.r; endfunction
endpackage
module top(output int o);
  import up::*;
  assign o = mk();
endmodule
