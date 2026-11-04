// § namedTypeLocalTfItemOutsideClass426
class A;
  int j;
endclass
function automatic integer test;
  A a1;
  a1 = new;
  test = a1.j;
endfunction
module top;
endmodule
