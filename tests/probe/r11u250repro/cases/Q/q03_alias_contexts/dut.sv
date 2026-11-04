// § pkgAliasOfKwTd250
package p;
  typedef int unsigned u_t;
  typedef u_t w_t;
  typedef byte b_t;
  typedef b_t c_t;
  function automatic w_t f(c_t a);
    w_t r;
    r = a;
    return r;
  endfunction
endpackage
module top;
  import p::*;
  w_t x;
  c_t y;
  initial x = f(y);
endmodule
