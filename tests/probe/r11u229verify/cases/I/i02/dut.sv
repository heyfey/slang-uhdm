// § ipsBasePfxScopeJoin224 (the base a function call in a class method)
package p1;
  typedef struct { logic [7:0] v; } e_t;
  class c;
    e_t arr[4];
    function int g(int x); return x + 1; endfunction
    function logic [1:0] f(int i, int k);
      return arr[i].v[g(k)+:2];
    endfunction
  endclass
endpackage
module top(output logic [1:0] o);
  import p1::*;
  c h;
  initial begin h = new; o = h.f(0, 1); end
endmodule
