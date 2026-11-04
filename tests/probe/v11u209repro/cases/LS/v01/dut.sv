// § tfItemLocalSpecAtName209: a paren-less package function local specialized from a generic of the same package
package p;
  class k #(int W = 1);
    int v = W;
  endclass
  function int g;
    k #(4) d;
    k #(5) e = null;
    return 0;
  endfunction
endpackage
module top;
  int r;
  initial r = p::g();
endmodule
