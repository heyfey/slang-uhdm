// § cloneMembEnumAtHomeListing265 (fresh: the member is typed by an alias of the enum typedef)
package p;
  typedef enum {OK, NOK} st_e;
  typedef st_e st2_e;
  typedef struct { int a; st2_e status; } op_t;
  class c;
    extern task f(output st_e s1);
  endclass
  task c::f(output st_e s1);
    begin
      op_t rw;
      s1 = rw.status;
    end
  endtask
  task g(output st_e s2, output st2_e s3);
    s2 = OK; s3 = NOK;
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
