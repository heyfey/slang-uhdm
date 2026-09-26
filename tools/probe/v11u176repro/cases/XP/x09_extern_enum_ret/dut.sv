// § externProtoFormalsFromPrototype175
package p;
  typedef enum {A, B} e_t;
  class k;
    extern function e_t f(e_t a);
  endclass
  function e_t k::f(e_t a);
    return a;
  endfunction
endpackage
module top;
  import p::*;
  k o; e_t r;
  initial begin o = new; r = o.f(B); end
endmodule
