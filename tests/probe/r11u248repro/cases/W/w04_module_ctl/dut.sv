// § cloneWithOperandChainName248
// control: no importer copy (module-scope class and a package class used by the module only)
package p;
  class c;
    int m_v[$];
    extern function void f(int lim);
  endclass
  function void c::f(int lim);
    int r[$];
    r = m_v.find(x) with (x > lim);
  endfunction
endpackage
module top;
  import p::*;
  class mc;
    int m_w[$];
    function void h(int lim);
      int r[$];
      r = m_w.find(x) with (x > lim);
    endfunction
  endclass
  c z;
  mc y;
  initial begin z = new(); y = new(); end
endmodule
