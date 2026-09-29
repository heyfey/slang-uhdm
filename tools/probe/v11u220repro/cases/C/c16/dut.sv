// § cloneHpIdxNamesByChain220
package p1;
  class node;
    int v;
    node kids[4];
  endclass
  class c;
    node root;
    extern function int f(int i, int j);
  endclass
  function int c::f(int i, int j);
    return root.kids[i].kids[j].v;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
