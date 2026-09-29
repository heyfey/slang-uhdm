// § ipsBasePfxScopeJoin224
package p1;
  typedef struct { logic [7:0] v; } s_t;
  class c;
    localparam int L = 2;
    s_t arr[4];
    function logic [1:0] f(int i, int k);
      return arr[i].v[k+:L];
    endfunction
  endclass
endpackage
module top; endmodule
