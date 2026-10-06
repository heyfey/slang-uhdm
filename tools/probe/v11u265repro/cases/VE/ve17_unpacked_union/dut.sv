// § cloneMembEnumAtHomeListing265 (fresh: an unpacked union with an enum member)
package p;
  typedef enum {OK, NOK} st_e;
  typedef union { int a; st_e status; } u_t;
  class c;
    extern task f(output st_e s1);
  endclass
  task c::f(output st_e s1);
    begin
      u_t u;
      s1 = u.status;
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
