// § cloneMembEnumAtHomeListing265 (fresh: an enum with an explicit logic [1:0] base in a packed struct)
package p;
  typedef enum logic [1:0] {OK, NOK, ERR} st_e;
  typedef struct packed { logic [3:0] a; st_e status; } op_t;
  class c;
    extern task f(output st_e s1);
  endclass
  task c::f(output st_e s1);
    begin
      op_t rw;
      rw = '0;
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
