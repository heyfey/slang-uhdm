// § cloneMembEnumAtHomeListing265 (the enum typedef has no formal writer: the listing stays at the typedef)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { int a; st_e status; } op_t;
  class c;
    extern function int f();
  endclass
  function int c::f();
    begin
      op_t rw;
      rw.a = 1;
      return rw.a;
    end
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
