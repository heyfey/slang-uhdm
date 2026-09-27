// § refFullNameThroughNamedExpr175
package p;
  class m; int arr [4]; int q [$]; endclass
  class k;
    m h;
    function int f(int idx, int j);
      int s;
      s = this.h.arr[idx];
      s += h.q[j];
      h.arr[idx] = s;
      return s;
    endfunction
  endclass
endpackage
module top; import p::*; k o; int r; initial begin o = new; r = o.f(0, 1); end endmodule
