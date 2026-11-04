// § cloneAliasCopyBareName484 (alias local in a task clone called from a module through an explicit import)
package u;
  typedef union { int k; int data; } op_t;
  typedef op_t op2_t;
  task t(output int o);
    op2_t acc;
    acc.k = 3;
    o = acc.data;
  endtask
endpackage
package a;
  import u::t;
  task g(output int o); t(o); endtask
endpackage
module top;
  import a::*;
  int x;
  initial g(x);
endmodule
