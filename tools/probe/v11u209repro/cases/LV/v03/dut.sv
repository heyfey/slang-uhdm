// § tfItemInitLocalAtType209: a class handle local with new in a paren-less package function
package p;
  class C;
    int v = 3;
  endclass
  function int f;
    C c = new;
    return c.v;
  endfunction
endpackage
module top;
  int r;
  initial r = p::f();
endmodule
