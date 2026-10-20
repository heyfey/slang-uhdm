// § foreachArrayNamesTypedef417
package p;
  class blk;
    int n;
    function int find(int m[$]);
      int b[$];
      b = m;
      foreach (b[idx]) n++;
      return n;
    endfunction
  endclass
endpackage
typedef int b;
module top;
endmodule
