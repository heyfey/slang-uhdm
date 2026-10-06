// § cloneLoopVarHomeDeclTs259 (a logic-vector typedef queue formal of a task, an importing module)
package p;
  typedef logic [7:0] b_t;
  task automatic t(ref b_t qq[$]);
    foreach (qq[i])
      qq[i] = 8'h0;
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
