// p6 — a package holding a CLASS with a method and a class-typed variable: the
// shape the head's chokepoint sits in (class_typespec -> class_defn).
package p6a;
  class c6;
    int v;
    function automatic int get(); return v; endfunction
  endclass
  typedef c6 c6_t;
endpackage
module top;
  import p6a::*;
  c6 h;
  initial begin h = new(); $display("%0d", h.get()); end
endmodule
