// § cloneTfVarParentAtTf482 (task with fork and locals)
package u;
  task automatic t(int n);
    int a0;
    a0 = n;
    fork
      begin int z; z = a0; end
    join
  endtask
endpackage
package a;
  import u::*;
  task automatic g(); t(1); endtask
endpackage
module top;
  import a::*;
  initial g();
endmodule
