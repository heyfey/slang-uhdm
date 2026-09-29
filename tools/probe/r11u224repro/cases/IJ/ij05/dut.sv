// § ipsBasePfxScopeJoin224
module top(output int o);
  typedef struct { logic [7:0] v; } s_t;
  class c;
    s_t arr[4];
    function logic [1:0] f(int i, int k);
      return arr[i].v[k+:2];
    endfunction
  endclass
  assign o = 1;
endmodule
