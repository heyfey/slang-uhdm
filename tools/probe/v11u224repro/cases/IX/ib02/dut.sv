// § ipsBasePfxScopeJoin224
package p1;
  typedef struct { logic [7:0] v; } s_t;
  class c;
    s_t arr[4];
    extern function logic [1:0] f(int i, int k);
  endclass
  function logic [1:0] c::f(int i, int k);
    return arr[i].v[k+:2];
  endfunction
endpackage
module top; endmodule
