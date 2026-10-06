// § cloneMembEnumAtHomeListing265 (the last formal writer is written inside a macro body)
`define DECL_T(N) task N(output st_e s); s = OK; endtask
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
  `DECL_T(g)
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
