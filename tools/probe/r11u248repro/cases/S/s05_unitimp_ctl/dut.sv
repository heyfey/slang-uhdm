// § cloneLoopVarClassPropStringTs248
// control: the home package is imported at $unit (the gate of § classPropUnitImport21)
package p;
  class c;
    string m_name;
    extern function int f();
  endclass
  function int c::f();
    int n;
    foreach (m_name[i]) n += m_name[i];
    return n;
  endfunction
endpackage
import p::*;
package q;
  import p::*;
  class u;
    function void g();
      c x;
      x = null;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  u w;
  initial w = new();
endmodule
