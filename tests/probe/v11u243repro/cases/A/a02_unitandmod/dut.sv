// § thisNetSurelogAnchor243
// a file-scope import written after a module import's package in the text
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
import p::*;
module top;
  import q::*;
  c o;
  d e;
endmodule
