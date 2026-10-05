// § foreachClassPropStringTsShared238
package p;
  typedef string str_t;
  class b;
    str_t m_al;
    string m_q[$];
  endclass
  virtual class c extends b;
    string m_n2;
    extern function int depth();
    pure virtual function int pv();
  endclass
  function int c::depth();
    foreach (m_al[i]) depth++;
    foreach (m_q[i]) foreach (m_q[i][j]) depth++;
    foreach (m_n2[k]) begin
      string m_n2;
      depth++;
    end
  endfunction
endpackage
module top;
endmodule
