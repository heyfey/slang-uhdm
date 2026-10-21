// § namedTypeLocalTfItemOutsideClass426
typedef struct { int a; } box_t;
module top;
  class C;
    int j;
    extern function integer f;
  endclass
  function integer C::f;
    box_t r;
    r.a = j;
    f = r.a;
  endfunction
  initial begin C c = new; $display(c.f()); end
endmodule
