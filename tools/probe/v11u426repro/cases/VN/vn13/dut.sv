// § namedTypeLocalTfItemOutsideClass426
class A;
  int j;
endclass
function integer f;
  A a1;
  A a2 = new;
  a1 = a2;
  f = a1.j;
endfunction
module top;
  initial $display(f());
endmodule
