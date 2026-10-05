// § foreachFlatLocalRefTs238
// a same-named variable in a WILDCARD-IMPORTED package (not the enclosing one)
package r;
  string vals[$];
endpackage
package p;
  import r::*;
  class c;
    extern function void m_set;
  endclass
  function void c::m_set;
    static string vals[$];
    string t[$];
    foreach (vals[i]) t.push_back(vals[i]);
  endfunction
  function void f;
    static int dd[];
    int s;
    foreach (dd[k]) s += dd[k];
  endfunction
endpackage
module top;
endmodule
