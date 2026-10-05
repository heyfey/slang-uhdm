// § lawSStringTd243
// an alias of a string typedef and a $unit string typedef
typedef string ustr_t;
package p;
  typedef string str_t;
  typedef str_t al_t;
  class c;
    al_t m_a;
    str_t m_s;
  endclass
endpackage
module top;
  import p::*;
  al_t a;
  ustr_t u;
  c o;
endmodule
