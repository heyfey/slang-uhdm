// § namedTypeLocalTfItemOutsideClass426
class C #(int W = 2);
  int j;
endclass
function integer test;
  C #(4) c1;
  c1 = new;
  test = c1.j;
endfunction
module top;
endmodule
