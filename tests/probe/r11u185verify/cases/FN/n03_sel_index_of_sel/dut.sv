// § refFullNameThroughNamedExpr175
package p;
  class k;
    int a [8];
    int b [4];
    function int f(int j);
      int s;
      s = a[b[j]];
      s += this.a[b[j + 1]];
      a[b[j]] = s;
      return s;
    endfunction
  endclass
endpackage
module top;
  int a [8], b [4], k, r;
  function automatic int g(int j); return a[b[j]]; endfunction
  initial r = g(k) + a[b[k]];
endmodule
