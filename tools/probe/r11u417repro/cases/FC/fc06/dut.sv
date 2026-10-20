// § foreachArrayNamesClass417
package p;
  class other;
    int v;
  endclass
  class blk;
    int n;
    extern function int find(int m[$]);
  endclass
  function int blk::find(int m[$]);
    int other[$];
    other = m;
    foreach (other[idx]) n++;
    return n;
  endfunction
endpackage
module top;
endmodule
