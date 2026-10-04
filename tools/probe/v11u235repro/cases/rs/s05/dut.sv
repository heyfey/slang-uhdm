// § clsTdClsEnumMemberShares235
package p;
class pol;
  typedef enum {X, Y} rs_e;
endclass
endpackage
module top;
  import p::*;
  typedef struct packed { logic [1:0] a; } m_t;
  class mc extends pol;
    typedef struct { rs_e state; m_t q; } si_t;
    si_t v;
  endclass
endmodule
