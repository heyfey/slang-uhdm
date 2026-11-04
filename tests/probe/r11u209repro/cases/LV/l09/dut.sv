// § tfItemLocalSpecAtName209: specialized class locals in methods with and without a port list
package p;
  class k #(int W = 1);
  endclass
  class c;
    function void f();
      k #(2) a = null;
      k #(3) b;
    endfunction
    function void g;
      k #(4) d;
      k #(5) e = null;
    endfunction
  endclass
endpackage
module top;
endmodule
