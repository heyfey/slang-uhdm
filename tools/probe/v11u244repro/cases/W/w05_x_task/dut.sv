// § cloneNewArrayCallParented244
package p;
  class fac;
    int m_sz; static int sz = 2;
    extern task run(output int d[]);
  endclass
  task fac::run(output int d[]);
    int k;
    k = m_sz;
    d = new[sz];
    d = new[k + sz];
    fork d = new[k]; join
  endtask
endpackage
package q;
  import p::*;
  class u; function void f(); fac x; x = null; endfunction endclass
endpackage
module top; import p::*; import q::*; fac z; u w; initial w = new(); endmodule
