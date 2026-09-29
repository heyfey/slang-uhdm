// § ipsBasePfxScopeJoin224
package p1;
  localparam int W = 2;
  typedef struct { logic [7:0] v; } s_t;
  class c;
    s_t arr[4];
    function logic [1:0] f(int i, int k);
      return arr[i].v[k+:W];
    endfunction
  endclass
endpackage
module top(output int o); assign o = 1; endmodule
