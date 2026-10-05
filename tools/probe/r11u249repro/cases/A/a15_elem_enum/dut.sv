// § clsPropWholeArrTd249
package p;
  typedef enum {A, B} e_t;
  typedef e_t ea_t[2];
  typedef struct { int x; } s_t;
  typedef s_t sa_t[];
  class c;
    ea_t m_e;
    sa_t m_s;
  endclass
endpackage
module top;
  import p::*;
  c o;
endmodule
