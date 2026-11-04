// § namedTypeLocalTfItemOutsideClass426
class A;
  int j;
endclass
module top;
  function integer f;
    A a1;
    a1 = new;
    f = a1.j;
  endfunction
  initial $display(f());
endmodule
