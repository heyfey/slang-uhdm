// § thisNetSurelogAnchor243
// two packages imported in the order opposite to their declaration
package p1;
  class c1;
    extern function void f();
  endclass
  function void c1::f();
    $display("%p", this);
  endfunction
endpackage
package p2;
  class c2;
    extern function void f();
  endclass
  function void c2::f();
    $display("%p", this);
  endfunction
endpackage
module top;
  import p2::*;
  import p1::*;
endmodule
