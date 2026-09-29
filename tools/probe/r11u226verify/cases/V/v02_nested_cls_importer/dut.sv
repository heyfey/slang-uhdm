// § importVarElemOwnName214 — a package dynamic array of a class inherited by a class nested inside a class of an importing package
package p;
  class item_c; int s; endclass
  item_c pool [];
  item_c qpool [$];
endpackage
package q;
  import p::*;
  class outer_c;
    class inner_c;
      int y;
    endclass
    int x;
  endclass
endpackage
module top;
endmodule
