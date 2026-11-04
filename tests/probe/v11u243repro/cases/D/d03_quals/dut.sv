// § clsPropLawSAliasName243
// static, rand, const, local and protected properties, two properties of one typedef, and a method local
package p;
  typedef int i_t;
  typedef byte y_t;
  class c;
    static i_t s_i;
    rand i_t r_i;
    const i_t c_i = 3;
    local y_t l_y;
    protected y_t p_y;
    i_t a, b;
    function i_t go(); i_t t; t = a + b + l_y + p_y; return t; endfunction
  endclass
endpackage
module top;
  import p::*;
  c o;
endmodule
