// § lawSStringTd243
// a package string typedef typing a module variable and a module function local
package p;
  typedef string str_t;
endpackage
module top;
  import p::*;
  str_t m;
  function int g();
    str_t q;
    q = "ab";
    return q.len();
  endfunction
  initial m = "a";
endmodule
