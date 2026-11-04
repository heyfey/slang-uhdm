// § cloneMembEnumAtHomeListing265 (fresh: the struct typedef and the last formal writer in an included header, the enum in dut.sv)
package p;
  typedef enum {OK, NOK} st_e;
  `include "w.svh"
  class c;
    extern task f(output st_e s1);
  endclass
  task c::f(output st_e s1);
    begin
      op_t rw;
      s1 = rw.status;
    end
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
