// § cloneNewArrayCallParented244
package p;
  class fac;
    int m_sz;
    extern function void emit(int n);
  endclass
  function void fac::emit(int n);
    int d[];
    int e[];
    d = new[n];
    e = new[d.size()](d);
    d = new[n << 1];
    d = new[n ? n : 1];
  endfunction
endpackage
package q;
  import p::*;
  class u; function void f(); fac x; x = null; endfunction endclass
endpackage
module top;
  import q::*;
  u w;
endmodule
