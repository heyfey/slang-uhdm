// § cloneLocalArrayTsParented241
package p;
  typedef struct { int a; } s_t;
  class fac;
    extern task run();
  endclass
  task fac::run();
    s_t sq[$];
    s_t dq[];
    foreach (sq[i]) sq[i].a = i;
    dq = new[1];
  endtask
endpackage
package q1;
  import p::*;
  class u; fac x; endclass
endpackage
package q2;
  import p::*;
  class v; fac y; endclass
endpackage
module top;
  import q1::*;
  import q2::*;
  u a; v b;
endmodule
