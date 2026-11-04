// § cloneFixArrAggElemShared482 (task local, two importers)
package u;
  typedef struct { int k; int data; } op_t;
  task automatic t(int n);
    op_t acc[2];
    acc[0].k = n;
    acc[1].data = acc[0].k;
  endtask
endpackage
package a;
  import u::*;
  task automatic g(); t(1); endtask
endpackage
package b;
  import u::*;
  task automatic h(); t(2); endtask
endpackage
module top;
  import a::*;
  import b::*;
  initial begin g(); h(); end
endmodule
