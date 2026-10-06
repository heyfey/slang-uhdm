// § cloneMembEnumAtHomeListing265 (fresh: a chain of importers, q imports p and r imports q, an interface imports p)
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
  export p::*;
  op_t x;
endpackage
package r;
  import q::*;
endpackage
interface ifc;
  import p::*;
endinterface
module top;
  import p::*;
  ifc i();
endmodule
