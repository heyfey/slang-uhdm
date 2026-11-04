// § thisNetSurelogAnchor243
// a bare this inside a macro body expanded in a later function: the wire sits at the earlier plain this
`define SHOWME $display("%p", this);
package p;
  class c;
    extern function void f1();
    extern function void f2();
  endclass
  function void c::f1();
    `SHOWME
  endfunction
  function void c::f2();
    $display("%p", this);
  endfunction
endpackage
module top;
  import p::*;
endmodule
