// § tfArgClassMethodOrder176
package p;
  typedef enum {A, B, C} e_t;
  class kz;
    extern function void f(e_t x);
  endclass
  class ka;
    extern function void g(e_t yy);
  endclass
  function void ka::g(e_t yy);
  endfunction
  function void kz::f(e_t x);
  endfunction
endpackage
module top;
  import p::*;
  kz o; ka q;
  initial begin o = new; q = new; o.f(B); q.g(C); end
endmodule
