// § thisNetSurelogAnchor243
// a nested class's method and a parameterized class's constructor
package p;
  class pc #(int W = 2);
    function new(); $display("%p", this); endfunction
  endclass
  class o;
    class inner;
      function void f(); $display("%p", this); endfunction
    endclass
    function void g(); $display("%p", this); endfunction
  endclass
endpackage
module top;
  import p::*;
  pc #(4) x;
endmodule
