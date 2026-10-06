// § cloneSharedAggOwnCopy265 (fresh: a module imports the importer package q, which re-exports the struct, and declares a variable of it)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { int a; st_e status; } op_t;
  class c;
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
  export p::op_t;
  export p::st_e;
  export p::OK;
endpackage
module top;
  import q::*;
  op_t v;
  initial v.status = OK;
endmodule
