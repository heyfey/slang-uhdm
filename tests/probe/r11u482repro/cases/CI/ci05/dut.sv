// § cloneFixArrAggElemShared482 (task local)
package u;
  typedef struct { int k; int data; } op_t;
  task automatic f(input int n, output int o);
    op_t acc[2];
    acc[0].k = n;
    o = acc[1].data;
  endtask
endpackage
package a;
  import u::*;
  task automatic g(output int r); f(1, r); endtask
endpackage
module top;
  import a::*;
  int x;
  initial g(x);
endmodule
