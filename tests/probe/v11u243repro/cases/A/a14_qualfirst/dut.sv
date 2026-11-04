// § thisNetSurelogAnchor243
// an imported package written first, a later package used only by p::c
package q;
  class d;
    function void g(); $display("%p", this); endfunction
  endclass
endpackage
package p;
  class c;
    function void f(); $display("%p", this); endfunction
  endclass
endpackage
module top;
  import q::*;
  p::c o;
  d e;
endmodule
