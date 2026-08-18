// r10uvm98 arm a2 — THE FENCE.  A name declared by EXACTLY ONE class: the
// first-writer IS the declaring class, so an inherited reference must bind to
// it and nothing may move.
package p98b;
  class zbase98 #(type T = int);
    typedef zbase98 #(T) sole_type;
    typedef int sole_int;
  endclass
  class zderv98 extends zbase98 #(int);
    function void f(sole_type prov); endfunction
    sole_int p;
  endclass
  class zoth98;                            // declares NEITHER name
    typedef bit other_t;
  endclass
endpackage

module top98b;
  import p98b::*;
  zbase98 #(int) hb;
  zderv98 hd;
  zoth98 ho;
  initial begin hb = new(); hd = new(); ho = new(); end
endmodule
