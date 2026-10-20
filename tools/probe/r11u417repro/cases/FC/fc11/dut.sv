// § foreachArrayNamesClass417
package p;
  class blk;
    int n;
    extern function int find_blocks(string name, ref blk blks[$]);
  endclass
  function int blk::find_blocks(string name, ref blk blks[$]);
    blk r[$];
    blk b[$];
    r = blks;
    foreach (r[i]) b.push_back(r[i]);
    foreach (b[idx]) n++;
    return b.size();
  endfunction
endpackage
import p::*;
class b;
  int v;
endclass
module top;
endmodule
