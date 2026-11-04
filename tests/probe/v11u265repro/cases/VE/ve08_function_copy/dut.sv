// § cloneSharedAggOwnCopy265 (fresh: a function, not a task, with the local; the home declares the same local too)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { int a; st_e status; } op_t;
  class c;
    extern function st_e f(int k);
    extern function st_e h(int k);
  endclass
  function st_e c::f(int k);
    op_t rw;
    rw.a = k;
    return rw.status;
  endfunction
  function st_e c::h(int k);
    op_t rw2;
    return rw2.status;
  endfunction
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
