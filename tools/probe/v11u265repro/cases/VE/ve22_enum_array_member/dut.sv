// § cloneMembEnumAtHomeListing265 (fresh: the member is an unpacked array of the enum, st_e sts[2], beside a plain enum member)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { st_e sts[2]; st_e status; } op_t;
  class c;
    extern task f(output st_e s1);
  endclass
  task c::f(output st_e s1);
    begin
      op_t rw;
      s1 = rw.sts[1];
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
