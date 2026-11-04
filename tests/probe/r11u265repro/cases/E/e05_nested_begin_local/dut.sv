// § cloneSharedAggOwnCopy265 (the local declared in a nested foreach body, as do_bus_write's rw_access)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { int a; st_e status; } op_t;
  class c;
    int vals[];
    extern task f(output st_e s1);
    extern task g(ref st_e s2);
  endclass
  task c::f(output st_e s1);
    foreach (vals[i]) begin
      op_t rw;
      rw.a = vals[i];
      s1 = rw.status;
    end
  endtask
  task c::g(ref st_e s2);
    s2 = NOK;
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
