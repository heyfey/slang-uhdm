// § cloneHpIdxNamesByChain220
package p1;
  class d; int m; endclass
  class e; d ch[4]; endclass
  class c;
    e comp;
    extern function int f(int leaf);
  endclass
  function int c::f(int leaf);
    return comp.ch[leaf].m;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
