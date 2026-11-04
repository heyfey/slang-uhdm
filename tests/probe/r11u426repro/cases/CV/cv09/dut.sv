// § namedTypeLocalTfItemOutsideClass426
class A;
  int j;
endclass
typedef A a_t;
function integer test;
  a_t a1;
  a1 = new;
  test = a1.j;
endfunction
module top;
endmodule
