// § cloneLocalArrayTsParented241
package p;
  class qc; int v; endclass
  function automatic int cnt();
    qc sq[$];
    qc dq[];
    int am[string];
    sq.delete();
    dq = new[2];
    return sq.size() + dq.size() + am.num();
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
  int x;
  initial x = cnt();
endmodule
