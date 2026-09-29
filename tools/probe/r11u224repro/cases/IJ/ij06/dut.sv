// § ipsBasePfxScopeJoin224
package p1;
  typedef struct { logic [7:0] v; } s_t;
  class c;
    s_t arr[4];
    function void f(int i, int k);
      arr[i].v[k+:2] = 2'b01;
    endfunction
  endclass
endpackage
module top(output int o); assign o = 1; endmodule
