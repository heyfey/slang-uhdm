// § thisNetSurelogAnchor243
// a module with its own unbindable scope name beside the forwarded this, the function later in the file than the constructor
package p;
  class c;
    int pv;
    extern function new();
    extern function void f();
  endclass
  function void c::f();
    pv = 1;
    $display("%p", this);
  endfunction
  function c::new();
    $display("%p", this);
  endfunction
endpackage
module top;
  import p::*;
  initial $dumpvars(0, top);
endmodule
