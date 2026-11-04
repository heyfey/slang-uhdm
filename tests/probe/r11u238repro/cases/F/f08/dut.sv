// § foreachClassPropStringTsShared238
package p;
  class b;
    string m_name;
  endclass
  class c extends b;
    string m_s;
    extern function int unsigned get_depth();
    function int f2(); int k; foreach (m_s[j]) k++; return k; endfunction
  endclass
  function int unsigned c::get_depth();
    foreach (m_name[i]) ++get_depth;
    foreach (m_s[i]) ++get_depth;
  endfunction
endpackage
module top;
endmodule
