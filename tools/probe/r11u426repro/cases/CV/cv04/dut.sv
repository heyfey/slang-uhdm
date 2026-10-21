// § namedTypeLocalTfItemOutsideClass426
class A;
  int j;
endclass
function integer test;
  A a1;
  int k;
  a1 = new;
  test = a1.j + k;
endfunction
module top;
endmodule
