// § tfItemLocalSpecAtName209: named and type-argument specializations in a paren-less method
package p;
  class k #(int W = 1, type T = int);
  endclass
  class c;
    function void g;
      k #(.W(4)) d;
      k #(2, byte) e;
    endfunction
  endclass
endpackage
module top;
endmodule
