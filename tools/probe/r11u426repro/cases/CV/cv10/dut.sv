// § namedTypeLocalTfItemOutsideClass426
class A;
  int j;
endclass
function integer test();
  A a1;
  a1 = new;
  test = a1.j;
endfunction
module top;
endmodule
