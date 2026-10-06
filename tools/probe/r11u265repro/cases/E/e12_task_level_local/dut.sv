// § cloneSharedAggOwnCopy265 (the local declared at the task level of the copy: stage 1 on both binaries, a package-order face)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { int a; st_e status; } op_t;
  class c;
    extern task f(output st_e s1);
    extern task g(output st_e s2);
  endclass
  task c::f(output st_e s1);
    op_t rw;
    rw.a = 1;
    s1 = rw.status;
  endtask
  task c::g(output st_e s2);
    s2 = OK;
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
