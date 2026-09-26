// § importCloneBodyLocalCopies175
package p1;
  typedef struct { int a; int b; } s_t;
  class H; int z; endclass
  function automatic int f(int n);
    s_t st = '{a:1, b:2};
    int q[$];
    int dyn[] = new[2];
    int aa[string];
    string nm = "x";
    H h = null;
    int u2[2][3];
    q.push_back(n);
    return st.a + q.size() + dyn.size() + u2[0][1];
  endfunction
endpackage
package p2;
  import p1::*;
  localparam int K = 1;
endpackage
module top; import p2::*; import p1::*; int r; initial r = f(1); endmodule
