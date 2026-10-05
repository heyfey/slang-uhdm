// § thisNetSurelogAnchor243
// an out-of-body definition written before a later class's in-body method
package p;
  class c0;
    extern function void f();
  endclass
  function void c0::f(); $display("%p", this); endfunction
  class c1;
    function void g(); $display("%p", this); endfunction
  endclass
endpackage
module top;
  import p::*;
endmodule
