// § cloneWithOperandChainName248
package p;
  virtual class vb;
    pure virtual function int pv(int lim, int k = 2);
  endclass
  class c extends vb;
    c m_sync[$];
    int m_v[$];
    bit m_pred[c];
    string m_name;
    extern function int pv(int lim, int k = 2);
    extern function void f(output bit r[c], input int lim);
  endclass
  function void c::f(output bit r[c], input int lim);
    int fi[$];
    fi = this.m_v.find(it) with (it == pv(.lim(lim), .k()));
    fi = m_sync.find_index(s) with (s.m_v.size() > pv(lim));
    foreach (r[x])
      foreach (x.m_pred[nx])
        r[nx] = 1;
    foreach (m_name[i]) fi.push_back(m_name[i]);
  endfunction
  function int c::pv(int lim, int k = 2);
    return m_v.sum() with (item * lim + k);
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
interface ifc;
  int qv[$];
  function automatic int cnt(int lim);
    int r[$];
    r = qv.find(z) with (z > lim);
    return r.size();
  endfunction
endinterface
module top(output logic o);
  import p::*;
  import q::*;
  u w;
  ifc i();
  assign imp = 1'b1;
  assign o = imp;
  initial w = new();
endmodule
