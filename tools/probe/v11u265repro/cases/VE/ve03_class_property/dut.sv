// § cloneSharedAggOwnCopy265 (fresh: the struct is a class property read by the copied method; the root is not the copy's)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { int a; st_e status; } op_t;
  class c;
    op_t prop;
    extern task f(output st_e s1);
  endclass
  task c::f(output st_e s1);
    s1 = prop.status;
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
