// § cloneArrElemAggOwnCopy482 (dynamic array in a task)
package u;
  typedef struct { int k; int data; } op_t;
  task automatic t(int n);
    op_t acc[];
    acc = new[2];
    acc[0].k = n;
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
