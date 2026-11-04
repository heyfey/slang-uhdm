// § pkgAliasOfKwTd250
package p;
  typedef longint l_t;
  typedef l_t m_t;
  typedef struct packed { m_t a; } s_t;
  class c;
    m_t f;
  endclass
endpackage
module top;
  import p::*;
  s_t s;
  c o;
endmodule
