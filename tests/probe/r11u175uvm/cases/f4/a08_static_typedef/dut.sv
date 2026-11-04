package p1;
  typedef int unsigned u_t;
  typedef enum {A, B} e_t;
  class base;
    extern static function u_t f(u_t a, input e_t e = A, ref int r);
  endclass
  function u_t base::f(u_t a, input e_t e = A, ref int r);
    return a;
  endfunction
endpackage
module top;
  import p1::*;
  int x;
  initial x = base::f(1, B, x);
endmodule
