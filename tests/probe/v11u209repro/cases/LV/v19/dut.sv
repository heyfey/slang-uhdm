// § tfItemInitLocalAtType209: a class-specialization local with an initializer in a paren-less package function
package p;
  class k #(int W = 1);
    int v = W;
  endclass
  function int g;
    k #(3) h = new;
    automatic k #(4) z = null;
    return h.v;
  endfunction
endpackage
module top;
  int r;
  initial r = p::g();
endmodule
