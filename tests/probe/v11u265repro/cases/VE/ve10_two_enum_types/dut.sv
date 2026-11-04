// § cloneMembEnumAtHomeListing265 (fresh: two different enum typedefs of the home as members, each with its own last writer)
package p;
  typedef enum {OK, NOK} st_e;
  typedef enum {RD, WR} kind_e;
  typedef struct { kind_e kind; int a; st_e status; } op_t;
  class c;
    extern task f(output st_e s1);
  endclass
  task c::f(output st_e s1);
    begin
      op_t rw;
      if (rw.kind == WR) s1 = rw.status;
    end
  endtask
  task g(output st_e s2, output kind_e k2);
    s2 = OK; k2 = RD;
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
