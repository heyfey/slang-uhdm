// § thisNetSurelogAnchor243
// only constructors use a bare this: the wire sits at the first constructor's this
package p;
  class c;
    extern function new();
  endclass
  class d;
    extern function new();
  endclass
  function d::new();
    $display("%p", this);
  endfunction
  function c::new();
    $display("%p", this);
  endfunction
endpackage
module top;
  import p::*;
endmodule
