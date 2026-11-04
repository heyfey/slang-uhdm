// § providerBodyCopyBind478 (a task with locals and a hier_path base)
package u;
  typedef struct { int k; int d; } s_t;
  task automatic t1(output int o);
    s_t s;
    int q;
    s.k = 3;
    q = s.k + 1;
    o = q;
  endtask
endpackage
package a;
  import u::*;
  class A;
    task g(); int o; t1(o); endtask
  endclass
endpackage
package t;
  import a::*;
  class T; A h; endclass
endpackage
module top; import t::*; T o; endmodule
