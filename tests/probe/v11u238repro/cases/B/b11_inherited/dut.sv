// § foreachFlatLocalRefTs238
// a paren-less derived-class method's local beside an INHERITED class property
package p;
  class b; int vals[4]; endclass
  class c extends b;
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
