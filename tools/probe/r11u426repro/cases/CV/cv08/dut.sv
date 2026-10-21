// § namedTypeLocalTfItemOutsideClass426
package p;
  class C;
    int j;
  endclass
endpackage
function integer test;
  p::C c1;
  c1 = new;
  test = c1.j;
endfunction
module top;
endmodule
