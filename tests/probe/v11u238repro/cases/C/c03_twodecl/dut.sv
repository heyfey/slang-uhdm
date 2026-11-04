// § foreachClassPropStringTsShared238
// two string properties in one declaration, a protected and a static string, an out-of-body method
package p;
  class b;
    string m_name, m_alt;
    protected string m_p;
    static string m_s;
    extern function int fx();
  endclass
  function int b::fx();
    int n;
    n = 0;
    foreach (m_name[i]) n++;
    foreach (m_alt[j]) n++;
    foreach (m_p[k]) n++;
    foreach (m_s[q]) n++;
    return n;
  endfunction
endpackage
module top;
endmodule
