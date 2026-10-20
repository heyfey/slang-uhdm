// residue (no law landed): a foreach array named like a $unit class or typedef (StmtEmit, decoded only), see README
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
import p::*;
typedef int b;
module top;
endmodule
