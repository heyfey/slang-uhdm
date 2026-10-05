// § lawSStringTd243
// a struct member, an unpacked struct and a module function's formal of a string typedef
package p;
  typedef string str_t;
  typedef struct { str_t n; int v; } rec_t;
  function automatic str_t name(rec_t r); return r.n; endfunction
endpackage
module top;
  import p::*;
  rec_t r;
  str_t s;
  initial begin r.n = "a"; s = name(r); end
endmodule
