// § foreachClassPropStringTsShared238
// two string properties in one declaration, protected/local/const/static string, a derived class shadowing
package p;
  class b;
    string m_name, m_alt;
    protected string m_p;
    local string m_l;
    static string m_s;
    function void fb();
      foreach (m_l[i]) m_p = m_l;
    endfunction
    extern function int fx();
  endclass
  function int b::fx();
    int n;
    foreach (m_name[i]) n++;
    foreach (m_alt[j]) n++;
    foreach (m_p[k]) n++;
    foreach (m_s[q]) n++;
    return n;
  endfunction
  class d extends b;
    string m_name;
    extern function int fd();
  endclass
  function int d::fd();
    int n;
    foreach (m_name[i]) n += m_name[i];
    foreach (super.m_name[i]) n++;
    return n;
  endfunction
endpackage
module top;
endmodule
