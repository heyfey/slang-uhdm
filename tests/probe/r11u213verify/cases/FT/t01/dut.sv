// § foreachThisArrAtThisToken207 (two and three loop indices, some skipped; associative, dynamic and queue dimensions)
package p;
  class C;
    int m2 [int][string];
    int m3 [][][];
    int dq [$][$];
    function void f();
      foreach (this.m2[i, j]) m2[i][j] = i;
      foreach (this.m3[i, j, k]) m3[i][j][k] = i + j + k;
      foreach (this.m3[i, j, ]) m3[i][j][0] = 0;
      foreach (this.dq[i, j]) dq[i][j]++;
    endfunction
  endclass
endpackage
module top; endmodule
