// § cloneHpIdxNamesByChain220
package p1;
  typedef struct { int a; } in_t;
  typedef struct { in_t q[3]; } s_t;
  class c;
    s_t arr[4];
    extern task t(int i, int j, output int o);
  endclass
  task c::t(int i, int j, output int o);
    o = arr[i].q[j].a;
  endtask
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
