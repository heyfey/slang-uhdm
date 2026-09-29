// § ipsBasePfxScopeJoin224
package p1;
  typedef struct { logic [7:0] v; } s_t;
  class c;
    s_t arr[4];
    function void f(int i, int k, logic [1:0] x);
      arr[i].v[k+:2] = x;
    endfunction
  endclass
endpackage
module top; endmodule
