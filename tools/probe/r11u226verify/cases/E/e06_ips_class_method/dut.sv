// § hpTrailIpsNamesByPath218 — a class method reading a member path's trailing indexed part select with a reference base
package p;
  typedef struct packed { logic [15:0] v; } r_t;
  class c;
    r_t r;
    function logic [3:0] get(int i);
      return r.v[i +: 4];
    endfunction
  endclass
endpackage
module top;
  import p::*;
endmodule
