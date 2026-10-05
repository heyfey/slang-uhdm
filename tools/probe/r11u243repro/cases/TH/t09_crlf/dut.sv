// § thisNetSurelogAnchor243
// CRLF: a constructor and a function using a bare this
package p;
  class c;
    extern function new();
    extern function void f();
  endclass
  function c::new();
    $display("%p", this);
  endfunction
  function void c::f();
    $display("%p", this);
  endfunction
endpackage
module top;
  import p::*;
endmodule
