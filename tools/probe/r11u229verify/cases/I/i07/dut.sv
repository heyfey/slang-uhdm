// § ipsBasePfxScopeJoin224 (a class nested in a class)
package p1;
  typedef struct { logic [7:0] v; } e_t;
  class o;
    class n;
      e_t arr[4];
      function logic [1:0] f(int i, int k);
        return arr[i].v[k+:2];
      endfunction
    endclass
  endclass
endpackage
module top(output logic [1:0] y);
  import p1::*;
  o::n h;
  initial begin h = new; y = h.f(0, 1); end
endmodule
