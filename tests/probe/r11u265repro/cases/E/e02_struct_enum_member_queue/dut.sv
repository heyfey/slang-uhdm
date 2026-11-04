// § cloneSharedAggOwnCopy265 (MiniAmiq #126482 reduced: the queue leg, `op_t acc[$]` in the copy)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { int a; st_e status; } op_t;
  class c;
    extern task f(output st_e s1);
    extern task g(output st_e s2);
  endclass
  task c::f(output st_e s1);
    begin
      op_t acc[$];
      op_t rw;
      acc.push_back(rw);
      s1 = acc[0].status;
    end
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
