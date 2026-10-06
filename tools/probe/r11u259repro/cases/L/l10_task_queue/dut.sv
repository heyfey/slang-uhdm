// § cloneLoopVarHomeDeclTs259 (a task over a queue formal of a logic typedef)
package p;
  typedef logic [3:0] n_t;
  task automatic t(ref n_t q[$], output int s);
    s = 0;
    foreach (q[k])
      s += q[k];
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
