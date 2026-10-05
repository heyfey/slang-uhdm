// § lawSStringTd243
// a package string typedef as a function formal, local and return in the home package
package p;
  typedef string str_t;
  function str_t f(str_t a);
    str_t l;
    l = a;
    return l;
  endfunction
endpackage
module top;
  import p::*;
  initial $display(f("x"));
endmodule
