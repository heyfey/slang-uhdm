// § classMethodLvIsProcess181 § lvSelIdxChainName181 (v11u181 break: extern method body, derived-class write of a base member, this-rooted)
typedef struct { int v; } s_t;
typedef struct { s_t w[4]; } m_t;
class B;
  m_t a;
  extern function void s(int j);
endclass
function void B::s(int j);
  a.w[j].v = 3;
  this.a.w[j+1].v = 4;
endfunction
class D extends B;
  function void t(int j);
    a.w[j].v = 7;
  endfunction
endclass
module top; initial begin D d = new; d.t(1); d.s(2); end endmodule
