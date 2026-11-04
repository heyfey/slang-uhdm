// § cloneMembEnumAtHomeListing265 (two enum members of two typedefs, and a struct member left alone)
package p;
  typedef enum {OK, NOK} st_e;
  typedef enum {RD, WR} k_e;
  typedef struct { int x; } in_t;
  typedef struct { k_e kind; in_t inner; st_e status; } op_t;
  class c;
    extern task f(output st_e s1, input k_e k1);
  endclass
  task c::f(output st_e s1, input k_e k1);
    begin
      op_t rw;
      rw.kind = k1;
      s1 = rw.status;
    end
  endtask
  task g(output st_e s2, input k_e k2);
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
