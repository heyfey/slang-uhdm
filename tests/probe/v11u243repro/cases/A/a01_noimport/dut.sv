// § thisNetSurelogAnchor243
// a package referenced by p::c without import (its this written first) beside an imported package
package p;
  class c;
    function void f(); $display("%p", this); endfunction
  endclass
endpackage
package q;
  class d;
    function void g(); $display("%p", this); endfunction
  endclass
endpackage
module top;
  import q::*;
  p::c o;
  d e;
endmodule
