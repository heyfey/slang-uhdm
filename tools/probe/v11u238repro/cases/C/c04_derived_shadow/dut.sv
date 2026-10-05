// § foreachClassPropStringTsShared238
// a derived class re-declaring the base's string property; super. and this. spellings
package p;
  class b;
    string m_name;
  endclass
  class d extends b;
    string m_name;
    extern function int fd();
  endclass
  function int d::fd();
    int n;
    n = 0;
    foreach (m_name[i]) n++;
    foreach (this.m_name[i]) n++;
    foreach (super.m_name[i]) n++;
    return n;
  endfunction
endpackage
module top;
endmodule
