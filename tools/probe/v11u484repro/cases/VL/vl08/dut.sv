// § modAliasPkgBaseTopView484v (module alias of a scoped package struct p::op_t)
package p;
  typedef struct { int k; int d; } op_t;
endpackage
module top;
  typedef p::op_t op2_t;
  task t(output int o);
    op2_t a;
    a.k = 1;
    o = a.k;
  endtask
  int x;
  initial t(x);
endmodule
