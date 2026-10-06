// § cloneSharedAggOwnCopy265 (fresh: two copied methods of two classes each declare a local of the struct)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { int a; st_e status; } op_t;
  class c;
    extern task f(output st_e s1);
  endclass
  class d;
    extern function st_e h();
  endclass
  task c::f(output st_e s1);
    begin
      op_t rw;
      s1 = rw.status;
    end
  endtask
  function st_e d::h();
    op_t z;
    return z.status;
  endfunction
  task g(output st_e s2);
    s2 = OK;
  endtask
endpackage
package q;
  import p::*;
endpackage
package q2;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
