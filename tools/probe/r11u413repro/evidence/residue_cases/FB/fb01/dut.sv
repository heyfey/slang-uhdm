// residue (no law landed): a foreach array named like a $unit class or typedef (StmtEmit, decoded only), see README
package p;
  class blk;
    int n;
    extern function int find(blk m[$]);
  endclass
  function int blk::find(blk m[$]);
    blk b[$];
    b = m;
    foreach (b[idx]) n++;
    return n;
  endfunction
endpackage
import p::*;
class b;
  int v;
endclass
module top;
endmodule
