// § methArgPathIdxAtHierPath270
package p;
  class info; int k; function int get(int y); return k + y; endfunction endclass
  class holder;
    info a[$];
    holder nx;
    function int has(int x); return 1; endfunction
  endclass
  class w;
    holder v;
    int r;
    task t(int i, int j);
      r = v.nx.has(v.a[i].get(v.a[j].k));
      r = v.has(v.nx.has(v.a[i].k));
      r = v.has(v.a[i].get(j)) + v.nx.a[j].get(v.a[i].k);
    endtask
  endclass
endpackage
module top;
  import p::*;
  w x;
endmodule
