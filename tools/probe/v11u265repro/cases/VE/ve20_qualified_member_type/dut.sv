// § cloneMembEnumAtHomeListing265 (fresh: the struct member and the writer formal are typed by the package-qualified name p::st_e)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { int a; p::st_e status; } op_t;
  class c;
    extern task f(output st_e s1);
  endclass
  task c::f(output st_e s1);
    begin
      op_t rw;
      s1 = rw.status;
    end
  endtask
  task g(output p::st_e s2);
    s2 = OK;
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
