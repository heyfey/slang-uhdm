// § cloneHierArrElemMember478 (a task writing a queue element member, two importers)
package u;
  typedef struct { int k; bit [63:0] data; } op_t;
  task automatic t(int n);
    op_t acc[$];
    acc.push_back('{1, 2});
    acc[0].data = n;
    acc[0].k = n + 1;
  endtask
endpackage
package a;
  import u::*;
  class A; task g(); t(1); endtask endclass
endpackage
package b;
  import u::*;
  class B; task g(); t(2); endtask endclass
endpackage
module top;
  import a::*; import b::*;
  A o; B p;
endmodule
