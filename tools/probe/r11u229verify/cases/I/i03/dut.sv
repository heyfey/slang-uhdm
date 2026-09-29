// § ipsBasePfxScopeJoin224 (the base a cast in a package function)
package p1;
  typedef struct { logic [7:0] v; } e_t;
  function automatic logic [1:0] f(e_t arr[4], int i, int k);
    return arr[i].v[int'(k)+:2];
  endfunction
endpackage
module top(output logic [1:0] o);
  import p1::*;
  e_t a[4];
  assign o = f(a, 0, 1);
endmodule
