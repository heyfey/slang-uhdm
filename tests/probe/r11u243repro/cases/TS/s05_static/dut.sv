// § lawSStringTd243
// static, protected and local string-typedef class properties and an out-of-body method local
package p;
  typedef string str_t;
  class b;
    static str_t s_al;
    protected str_t m_p;
    local str_t m_l;
    extern function str_t get();
  endclass
  function str_t b::get();
    str_t t;
    t = m_p;
    return t;
  endfunction
endpackage
module top;
  import p::*;
  b o;
endmodule
