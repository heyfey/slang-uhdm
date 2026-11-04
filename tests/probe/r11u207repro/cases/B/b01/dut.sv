// § bitSelMethodCallIdxSpan207: rvalue selects indexed by a handle's method call, with and without arguments (BuildUVMPkg m_children); lvalue and plain-call controls
package p;
class C;
  C m_ch[string];
  int m_i[int];
  string nm;
  function string get_name(); return nm; endfunction
  function int gi(int a = 0); return a; endfunction
  function bit add(C child);
    if (m_ch.exists(child.get_name()) &&
        m_ch[child.get_name()] != child) return 0;
    if (m_ch[get_name()] != child) return 0;
    if (m_i[child.gi(1)] != 0) return 0;
    if (m_i[gi(2)] != 0) return 0;
    if (m_i[child.gi()] != 0) return 0;
    if (m_i[child.gi(child.gi(3))] + m_i[(child.gi(4))] > 1) return 0;
    m_i[child.gi()] = 1;
    return m_ch[child.get_name] == null;
  endfunction
endclass
endpackage
module top; endmodule
