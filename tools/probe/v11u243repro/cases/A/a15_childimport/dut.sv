// § thisNetSurelogAnchor243
// the top imports the package written first; a child module imports a later package
package p2;
  class c2;
    function void g(); $display("%p", this); endfunction
  endclass
endpackage
package p1;
  class c1;
    function void f(); $display("%p", this); endfunction
  endclass
endpackage
module child;
  import p1::*;
  c1 a;
endmodule
module top;
  import p2::*;
  c2 b;
  child u();
endmodule
