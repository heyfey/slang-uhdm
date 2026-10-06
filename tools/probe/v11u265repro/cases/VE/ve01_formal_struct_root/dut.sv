// § cloneSharedAggOwnCopy265 (fresh: the struct is a formal of the copied method, not a local)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { int a; st_e status; } op_t;
  class c;
    extern task f(input op_t x, output st_e s1);
    extern task g(output st_e s2);
  endclass
  task c::f(input op_t x, output st_e s1);
    s1 = x.status;
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
