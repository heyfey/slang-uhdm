// § cloneNewArrayCallParented244
package p;
  class fac;
    int m_sz; static int sz = 2;
    task automatic run(output int d[]);
      d = new[sz];
      d = new[m_sz + sz];
    endtask
    static function void sf(ref int d[]); d = new[sz]; endfunction
  endclass
endpackage
package q;
  import p::*;
  class u; function void f(); fac x; x = null; endfunction endclass
endpackage
module top; import p::*; import q::*; fac z; u w; initial w = new(); endmodule
