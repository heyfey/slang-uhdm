// § ipsBasePfxScopeJoin224
package p1;
  typedef struct { logic [7:0] v; } s_t;
  s_t arr[4];
  function automatic logic [1:0] f(int i, int k);
    return arr[i].v[k+:2];
  endfunction
endpackage
module top(output logic [1:0] o);
  import p1::*;
  assign o = f(1, 2);
endmodule
