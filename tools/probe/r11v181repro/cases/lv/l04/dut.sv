// § classMethodLvIsProcess181 (v11u181 break: parameterized class, class in a package, this-rooted, a derived class writing a base member)
package p;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  class B #(int N = 2);
    m_t a;
    function void s(int j);
      a.w[j].v = N;
      this.a.w[j].v = 1;
    endfunction
  endclass
  class D extends B#(4);
    function void t(int j);
      a.w[j+1].v = 7;
      super.s(j);
    endfunction
  endclass
endpackage
module top;
  initial begin static p::D d = new; d.t(1); end
endmodule
