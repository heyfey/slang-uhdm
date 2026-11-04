// § cloneSharedAggOwnCopy265 (fresh: the local is declared in a fork-join block and in a named begin of the copy)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { int a; st_e status; } op_t;
  class c;
    extern task f(output st_e s1);
  endclass
  task c::f(output st_e s1);
    fork
      begin : nb
        op_t rw;
        s1 = rw.status;
      end
    join
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
