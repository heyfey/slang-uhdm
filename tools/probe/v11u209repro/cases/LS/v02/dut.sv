// § tfItemLocalSpecAtName209: a generic imported from another package, specialized in a paren-less method
package q;
  class k #(int W = 1);
  endclass
endpackage
package p;
  import q::*;
  class c;
    function void g;
      k #(4) d;
    endfunction
  endclass
endpackage
module top;
endmodule
