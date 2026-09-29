// § opIdxRecvElemFollowsPath215 — a $unit class and a package class with two-level receivers (a[i-1].b[j+1].m()) and an index read through this
package p;
  class leaf; function int m(); return 1; endfunction endclass
  class mid; leaf b[4]; endclass
  class top_c;
    mid a[4];
    int j;
    function int f(int i);
      return a[i-1].b[j+1].m() + a[this.j-1].b[0].m();
    endfunction
  endclass
endpackage
class uc;
  p::mid a[4];
  function int f(int i, int j);
    return a[i+1].b[j-1].m();
  endfunction
endclass
module m;
endmodule
