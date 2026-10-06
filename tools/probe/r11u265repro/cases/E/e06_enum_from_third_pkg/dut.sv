// § cloneMembEnumAtHomeListing265 (abstains: the member's enum is a third package's typedef)
package r;
  typedef enum {OK, NOK} st_e;
endpackage
package p;
  import r::*;
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
endpackage
module top;
  import p::*;
endmodule
