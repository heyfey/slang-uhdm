// § cloneMembEnumAtHomeListing265 (the typedef and the formal writer in an included CRLF header)
package p;
  `include "defs.svh"
  class c;
    extern task f(output st_e s1);
  endclass
  task c::f(output st_e s1);
    op_t rw;
    s1 = rw.status;
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
