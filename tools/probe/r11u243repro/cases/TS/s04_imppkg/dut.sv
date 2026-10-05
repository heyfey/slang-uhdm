// § lawSStringTd243
// a string typedef used by a function and a class property in an importing package
package p;
  typedef string str_t;
endpackage
package q;
  import p::*;
  class c;
    str_t nm;
  endclass
  function str_t h(str_t a); return a; endfunction
endpackage
module top;
  import q::*;
  c o;
endmodule
