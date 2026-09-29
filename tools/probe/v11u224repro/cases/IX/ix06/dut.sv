// § ipsBasePfxScopeJoin224
package p1;
  typedef struct { logic [7:0] v; } s_t;
  class c #(type T = int, int W = 2);
    s_t arr[4];
    function logic [W-1:0] f(int i, int k);
      return arr[i].v[k+:W];
    endfunction
  endclass
  typedef c#(byte, 3) c3_t;
endpackage
module top(output logic [2:0] o);
  p1::c3_t h;
  initial begin h = new; o = h.f(0, 1); end
endmodule
