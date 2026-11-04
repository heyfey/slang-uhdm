// § cloneHpIdxNamesByChain220 § cloneIdxOwnCopyOnly220 — clone select indices: a nested select as an index, a cast index and an index inside an lvalue path, in a task
package p1;
  typedef struct { int m; } e_t;
  class c;
    e_t tab [8];
    int ix [4];
    extern task t(int i, output int o);
  endclass
  task c::t(int i, output int o);
    o = tab[ix[i]].m + tab[int'(i)].m;
    tab[i].m = o;
  endtask
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 0;
endmodule
