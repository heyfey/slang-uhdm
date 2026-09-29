// § ipsWidthPfxByPathInScope224
package p1;
  typedef struct { logic [7:0] v; } s_t;
  class c #(int W = 2);
    s_t arr[4];
    function logic [W-1:0] f(int i, int k);
      return arr[i].v[k+:W*1];
    endfunction
  endclass
  class d extends c #(4);
  endclass
endpackage
module top(output int o); assign o = 1; endmodule
