// § cloneNewArrayCallParented244
package p;
  class fac;
    int m_sz; int md[]; byte bits[];
    function int g(int a); return a + 1; endfunction
    extern function void emit(int n);
  endclass
  function void fac::emit(int n);
    int d[]; int e[];
    d = new[n];
    e = new[n](d);
    md = new[m_sz * 2];
    this.md = new[g(n)];
    bits = new[$clog2(n) + 1];
    begin d = new[d.size() + 1](d); end
    foreach (d[i]) e = new[i];
    if (n > 1) md = new[n] (md);
  endfunction
endpackage
package q;
  import p::*;
  class u; function void f(); fac x; x = null; endfunction endclass
endpackage
module top; import p::*; import q::*; fac z; u w; initial w = new(); endmodule
