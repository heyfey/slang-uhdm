// § cloneWithOperandChainName248
package p;
  class c;
    static int s_v[$];
    extern static function int f(int lim);
  endclass
  function int c::f(int lim);
    int r[$];
    r = s_v.find_first(x) with (x >= lim);
    r = c::s_v.find(y) with (y != lim);
    return r.size();
  endfunction
endpackage
package q;
  import p::*;
  class u;
    function void g();
      c x;
      x = null;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  u w;
  initial w = new();
endmodule
