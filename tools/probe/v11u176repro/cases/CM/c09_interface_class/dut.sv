// § tfArgClassMethodOrder176
package p;
  typedef enum {A, B, C} e_t;
  interface class ic;
    pure virtual function void f(e_t x);
  endclass
  class k implements ic;
    virtual function void f(e_t x);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  k o;
  initial begin o = new; o.f(B); end
endmodule
