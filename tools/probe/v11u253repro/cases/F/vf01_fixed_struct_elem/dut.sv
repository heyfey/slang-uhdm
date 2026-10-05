// § cloneTfFixedArrTsParented253 (a fixed array of a package struct, a 2-D fixed array, a typedef'd element)
package p;
  typedef struct packed { logic [3:0] a; } s_t;
  typedef logic [7:0] b_t;
  function automatic int f(int k);
    s_t sa[3];
    b_t ba[2][2];
    int n = 0;
    sa[0].a = k;
    ba[1][1] = k;
    foreach (sa[i]) n += sa[i].a;
    return n + ba[1][1];
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
