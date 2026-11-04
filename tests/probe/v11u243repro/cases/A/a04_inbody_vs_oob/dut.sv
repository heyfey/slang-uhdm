// § thisNetSurelogAnchor243
// an out-of-body definition written after another class's in-body method
package p;
  class c0;
    extern function void f();
  endclass
  class c1;
    function void g(); $display("%p", this); endfunction
  endclass
  function void c0::f(); $display("%p", this); endfunction
endpackage
module top;
  import p::*;
endmodule
