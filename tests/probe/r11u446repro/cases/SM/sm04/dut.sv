// § aggCopyClassMemberHomeInst446
package p;
  typedef class W;
  typedef struct {W m_type;
                  string m_name;} s_t;
  class W;
  endclass
  class F;
    extern function bit match(s_t a);
    function bit loc();
      s_t b;
      return b.m_type == null;
    endfunction
  endclass
  function bit F::match(s_t a);
    s_t c;
    return a.m_type == c.m_type;
  endfunction
endpackage
module top;
  import p::*;
  F f;
endmodule
