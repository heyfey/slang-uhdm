// § foreachArrayNamesClass417
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
import p::*;
class b;
  int v;
endclass
module top;
endmodule
