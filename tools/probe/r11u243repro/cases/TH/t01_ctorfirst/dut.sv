// § thisNetSurelogAnchor243
// a constructor written first and two functions using a bare this: the wire sits at the first function's this
package p;
  class c;
    int v;
    extern function new();
    extern function void f1();
    extern function void f2();
  endclass
  function c::new();
    $display("%p", this);
  endfunction
  function void c::f1();
    $display("%p", this);
  endfunction
  function void c::f2();
    $display("%p", this);
  endfunction
endpackage
module top;
  import p::*;
  logic clk;
endmodule
