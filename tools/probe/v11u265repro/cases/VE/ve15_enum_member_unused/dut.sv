// § cloneSharedAggOwnCopy265 (fresh: the local's enum member is never read; only the int member is)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { int a; st_e status; } op_t;
  class c;
    extern task f(output int s1);
  endclass
  task c::f(output int s1);
    begin
      op_t rw;
      rw.a = 3;
      s1 = rw.a;
    end
  endtask
  task g(output st_e s2);
    s2 = OK;
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
