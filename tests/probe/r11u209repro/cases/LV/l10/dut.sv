// § tfItemLocalSpecAtName209: specialized class properties and module variables
package p;
  class k #(int W = 1);
  endclass
  class c;
    k #(2) a;
    k #(.W(3)) b;
  endclass
endpackage
module top;
  p::k #(4) m;
endmodule
