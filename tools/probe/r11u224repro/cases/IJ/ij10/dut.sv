// § ipsBasePfxScopeJoin224
package p1;
  typedef struct { logic [7:0] v; } s_t;
  typedef struct { s_t m; } w_t;
  class c;
    w_t arr[4];
    function logic [1:0] f(int i, int k);
      return arr[i].m.v[k+:2];
    endfunction
  endclass
endpackage
module top(output int o); assign o = 1; endmodule
