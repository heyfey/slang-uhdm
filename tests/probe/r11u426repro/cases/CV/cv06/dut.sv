// § namedTypeLocalTfItemOutsideClass426
typedef struct { int a; } box_t;
class A;
  int j;
endclass
function integer test;
  box_t r;
  A a1;
  a1 = new;
  test = a1.j + r.a;
endfunction
module top;
endmodule
