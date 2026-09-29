// § ipsBasePfxScopeJoin224
package p1;
  typedef struct { logic [7:0] v; } s_t;
  typedef struct { s_t e[2]; } w_t;
  class c;
    w_t arr[4];
    function logic [1:0] f(int i, int j, int k);
      return arr[i].e[j].v[k+:2];
    endfunction
  endclass
endpackage
module top; endmodule
