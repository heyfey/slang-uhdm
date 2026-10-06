// § cloneLoopVarLocalElemTs252
package p;
  class comp;
    task run;
      string names[$];
      foreach (names[k]) $display(names[k]);
    endtask
  endclass
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
