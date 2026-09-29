// § ipsWidthPfxByPathInScope224 (the width a class localparam)
package p1;
  typedef struct { logic [7:0] v; } e_t;
  class c;
    localparam int W = 2;
    e_t arr[4];
    function logic [1:0] f(int i, int k);
      return arr[i].v[k+:W];
    endfunction
  endclass
endpackage
module top(output logic [1:0] o);
  import p1::*;
  c h;
  initial begin h = new; o = h.f(0, 1); end
endmodule
