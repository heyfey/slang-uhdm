// § ipsBasePfxScopeJoin224 (a static class function called from a module)
package p1;
  typedef struct { logic [7:0] v; } e_t;
  class c;
    static function logic [1:0] f(e_t arr[4], int i, int k);
      return arr[i].v[k+:2];
    endfunction
  endclass
endpackage
module top(output logic [1:0] o);
  import p1::*;
  e_t a[4];
  initial o = c::f(a, 0, 1);
endmodule
