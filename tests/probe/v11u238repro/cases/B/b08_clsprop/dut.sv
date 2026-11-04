// § foreachFlatLocalRefTs238
// a paren-less class method's local beside a same-named class property
package p;
  class c;
    int vals[4];
    extern function void m_set;
  endclass
  function void c::m_set;
    static string vals[$];
    string t[$];
    foreach (vals[i]) t.push_back(vals[i]);
  endfunction
endpackage
module top;
endmodule
