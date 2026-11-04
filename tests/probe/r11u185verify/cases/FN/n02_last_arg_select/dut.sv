// § refFullNameThroughNamedExpr175
package p;
  class h; function int e(int a, int b = 0); return a + b; endfunction endclass
  class k;
    h o;
    int arr [4];
    int q [$];
    function int f(int idx);
      int s;
      s = o.e(idx, arr[idx]);
      s += o.e(arr[idx + 1]);
      s += o.e(q[idx], q[$]);
      return s;
    endfunction
  endclass
endpackage
module top; import p::*; k c; int r; initial begin c = new; r = c.f(0); end endmodule
