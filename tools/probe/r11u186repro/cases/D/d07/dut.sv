// § enumConstUnderscoreDropped186 (an interface enum and a package enum read through an import)
package p;
  typedef enum { K = 1_1, L = 2_2 } k_t;
endpackage
interface itf;
  typedef enum int { M = 4_4 } m_t;
  m_t v;
endinterface
module top;
  import p::*;
  itf i();
  k_t f;
endmodule
