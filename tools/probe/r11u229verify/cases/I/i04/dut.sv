// § ipsBasePfxScopeJoin224 (the base a struct member in a class method)
package p1;
  typedef struct { logic [7:0] v; } e_t;
  typedef struct { int k; } s_t;
  class c;
    e_t arr[4];
    function logic [1:0] f(int i, s_t s);
      return arr[i].v[s.k+:2];
    endfunction
  endclass
endpackage
module top(output logic [1:0] o);
  import p1::*;
  c h; s_t s;
  initial begin h = new; s.k = 1; o = h.f(0, s); end
endmodule
