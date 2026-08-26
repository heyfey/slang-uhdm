package pq155v;
  class KNone155v; int f; endclass
  class KExpl155v; int f; endclass
  class KWild155v; int f; endclass
  class KSame155v; int f; endclass
endpackage
module m1155v;                       // NO import — a class of the same name exists only in pq155v
  initial begin
    typedef int KNone155v;
    KNone155v v1155v;
    v1155v = 1;
  end
endmodule
module m2155v;                       // EXPLICIT import of the class
  import pq155v::KExpl155v;
  initial begin
    typedef int KExpl155v;
    KExpl155v v2155v;
    v2155v = 2;
  end
endmodule
module m3155v;                       // WILDCARD import
  import pq155v::*;
  initial begin
    typedef int KWild155v;
    KWild155v v3155v;
    v3155v = 3;
  end
endmodule
package pq2155v;                     // the class is in the SAME scope chain
  class KLoc155v; int f; endclass
  function automatic int f4155v();
    typedef int KLoc155v;
    KLoc155v v4155v;
    v4155v = 4;
    return v4155v;
  endfunction
endpackage
