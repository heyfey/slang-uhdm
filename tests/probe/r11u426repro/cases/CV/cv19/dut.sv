// § namedTypeLocalTfItemOutsideClass426
class A;
  int j;
endclass
function integer test;
  static A a1;
  automatic A a2;
  a1 = new;
  test = a1.j;
endfunction
module top;
endmodule
