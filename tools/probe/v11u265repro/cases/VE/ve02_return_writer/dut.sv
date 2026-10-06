// § cloneMembEnumAtHomeListing265 (fresh: the enum's last writer is a function return type, not a formal)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { int a; st_e status; } op_t;
  class c;
    extern task f(output int s1);
  endclass
  task c::f(output int s1);
    begin
      op_t rw;
      s1 = rw.a;
      if (rw.status == OK) s1 = 2;
    end
  endtask
  function st_e g();
    return OK;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
