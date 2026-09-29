// § hpLvSelIdxNamesByPath224 § ipsBasePfxScopeJoin224 § sysCallTypeArgScopeJoin224 § hpLvNewClassFirstElemSpan224 (four expression laws in one class method, the importer clone)
package p;
  typedef struct { logic [7:0] v; logic [3:0] arr [4]; } e_t;
  class s; endclass
  class r; s parent; endclass
  class c;
    typedef logic [2:0] l_t;
    e_t arr[4]; e_t st; r rw;
    function int f(int i, int k);
      st.arr[i][1:0] = 2'b01;
      rw = new; rw.parent = new;
      return $bits(l_t) + arr[i].v[k+:2];
    endfunction
  endclass
endpackage
package q;
  import p::*;
  class d extends c; endclass
endpackage
module top(output int o);
  import q::*;
  d h;
  initial begin h = new; o = h.f(1, 2); end
endmodule
