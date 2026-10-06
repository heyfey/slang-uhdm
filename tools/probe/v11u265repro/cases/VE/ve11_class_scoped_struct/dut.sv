// § cloneSharedAggOwnCopy265 (fresh: the struct typedef is declared inside the class, its enum member the package's)
package p;
  typedef enum {OK, NOK} st_e;
  class c;
    typedef struct { int a; st_e status; } op_t;
    extern task f(output st_e s1);
  endclass
  task c::f(output st_e s1);
    begin
      op_t rw;
      s1 = rw.status;
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
