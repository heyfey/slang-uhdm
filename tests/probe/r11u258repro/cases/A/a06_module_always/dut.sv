// § cloneLoopVarAssocIdxTs258 (a module always block over a struct-indexed associative array: no copy, the law must not fire)
package p;
  typedef struct packed {
    bit [7:0] lo;
    bit [7:0] hi;
  } rng_t;
endpackage
module top;
  import p::*;
  int m[rng_t];
  int n;
  always_comb begin
    n = 0;
    foreach (m[r])
      n += r.lo;
  end
endmodule
