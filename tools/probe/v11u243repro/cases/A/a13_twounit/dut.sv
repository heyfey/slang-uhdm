// § thisNetSurelogAnchor243
// two file-scope imports written against their packages' text order
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
import p2::*;
import p1::*;
module top;
  c1 a;
  c2 b;
endmodule
