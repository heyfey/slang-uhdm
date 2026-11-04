// § foreachArrayNamesClass417
package p;
  class blk;
    int n;
    extern function int find(int m[$]);
  endclass
  function int blk::find(int m[$]);
    int b[$];
    b = m;
    foreach (b[idx]) n++;
    return n;
  endfunction
endpackage
class b;
  int v;
endclass
module top;
endmodule
