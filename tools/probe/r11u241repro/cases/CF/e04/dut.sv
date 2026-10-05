// § cloneAggTsAtHomeListing241
package p;
  typedef struct packed { logic [1:0] hi; logic lo; } k_t;
  function automatic int f1(k_t a);
    k_t loc;
    loc = a;
    return int'(loc.hi);
  endfunction
  function automatic int f2(k_t b);
    return int'(b.lo);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
  int x;
  initial x = f1(3'd1) + f2(3'd2);
endmodule
