// § tfArgClassMethodOrder176
package p;
  typedef enum {A, B, C} e_t;
  class base;
    virtual function void f(e_t x);
    endfunction
  endclass
endpackage
package q;
  import p::*;
  class der extends base;
    virtual function void f(e_t x);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  der o;
  initial begin o = new; o.f(B); end
endmodule
