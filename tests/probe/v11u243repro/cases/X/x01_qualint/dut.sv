// § lawSStringTd243 (int control)
// a package-qualified string typedef with no import, and a class in another package
package p;
  typedef int str_t;
endpackage
package q;
  class c;
    p::str_t m;
    function p::str_t f(p::str_t a); p::str_t l; l = a; return l; endfunction
  endclass
endpackage
module top;
  p::str_t s;
  q::c o;
endmodule
