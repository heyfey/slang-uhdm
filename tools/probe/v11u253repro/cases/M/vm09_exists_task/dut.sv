// § cloneMintParentHomeCall253 (a task)
package p;
  class keep_c; endclass
  task automatic t(int k, output int r);
    int seen[int];
    r = seen.exists(k);
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
