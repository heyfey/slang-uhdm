// § classMethodLvIsProcess181 § lvSelIdxChainName181 § procLvIdxCallWholeSpan181 (r11u190: a method of a PACKAGE class called from a module; a call index)
package p;
  typedef struct { int v; } s_t;
  typedef struct { s_t w [4]; } m_t;
  class C;
    m_t q;
    function int idx(int j); return j & 3; endfunction
    function void g(int j);
      q.w[j].v = 1;
      q.w[idx(j)].v = 2;
    endfunction
  endclass
endpackage
module top;
  initial begin
    p::C c = new;
    c.g(2);
  end
endmodule
