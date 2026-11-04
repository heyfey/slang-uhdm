// § cloneSharedAggOwnCopy265 (fresh: two locals of the struct in one copy, one at the task level and one in a begin, plus a class property)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { int a; st_e status; } op_t;
  class c;
    op_t prop;
    extern task f(output st_e s1);
  endclass
  task c::f(output st_e s1);
    op_t r1;
    begin
      op_t r2;
      s1 = r2.status;
    end
    s1 = r1.status;
    prop = r1;
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
