// § importCloneBodyLocalCopies175
package p1;
  function automatic int fa(int n);
    static int cnt = 0;
    int t = n;
    cnt++;
    return cnt + t;
  endfunction
  function int fs(int n);
    automatic int u = n;
    int v;
    v = u + 1;
    return v;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top; int r; initial r = p1::fa(1) + p1::fs(2); endmodule
