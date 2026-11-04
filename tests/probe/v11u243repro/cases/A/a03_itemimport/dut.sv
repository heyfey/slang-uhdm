// § thisNetSurelogAnchor243
// an explicit item import of the second package, a wildcard import of the first
package p1;
  class c1;
    function void f(); $display("%p", this); endfunction
  endclass
endpackage
package p2;
  class c2;
    function void g(); $display("%p", this); endfunction
  endclass
endpackage
module top;
  import p2::c2;
  import p1::*;
  c2 o;
  c1 e;
endmodule
