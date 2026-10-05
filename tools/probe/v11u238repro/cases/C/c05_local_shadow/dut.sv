// § foreachClassPropStringTsShared238
// a method-local string shadowing the property; a formal named like the property; a body-local string
package p;
  class b;
    string m_name;
    string m_other;
    extern function int fa();
    extern function int fb(string m_other);
  endclass
  function int b::fa();
    string m_name;
    int n;
    n = 0;
    foreach (m_name[i]) n++;
    return n;
  endfunction
  function int b::fb(string m_other);
    int n;
    n = 0;
    foreach (m_other[i]) n++;
    return n;
  endfunction
endpackage
module top;
endmodule
