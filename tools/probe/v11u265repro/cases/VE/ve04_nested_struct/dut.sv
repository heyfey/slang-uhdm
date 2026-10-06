// § cloneMembEnumAtHomeListing265 (fresh: the enum member sits one level down, in a nested struct member)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { int b; st_e st; } in_t;
  typedef struct { int a; in_t inner; st_e status; } op_t;
  class c;
    extern task f(output st_e s1);
  endclass
  task c::f(output st_e s1);
    begin
      op_t rw;
      s1 = rw.inner.st;
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
