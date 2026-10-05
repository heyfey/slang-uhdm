// § foreachFlatLocalRefTs238
// a same-named package PARAMETER and a same-named class property beside the paren-less local
package p;
  parameter int vals = 3;
  class c;
    int qq[$];
    extern function void m_set;
  endclass
  function void c::m_set;
    static string vals[$];
    static string qq[$];
    string t[$];
    foreach (vals[i]) t.push_back(vals[i]);
    foreach (qq[i]) t.push_back(qq[i]);
  endfunction
endpackage
module top;
endmodule
