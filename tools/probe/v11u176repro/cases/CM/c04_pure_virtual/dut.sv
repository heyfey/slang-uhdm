// § tfArgClassMethodOrder176
package p;
  typedef enum {A, B, C} e_t;
  virtual class base;
    pure virtual function void f(e_t x);
  endclass
  class der extends base;
    virtual function void f(e_t x);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  der o;
  initial begin o = new; o.f(B); end
endmodule
