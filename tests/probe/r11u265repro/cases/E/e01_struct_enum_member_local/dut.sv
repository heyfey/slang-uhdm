// § cloneSharedAggOwnCopy265 (MiniAmiq #126534 reduced: a struct with an enum member, a local of an extern method copied into an importer; the home also declares one)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { int a; st_e status; } op_t;
  class c;
    extern task f(output st_e s1);
    extern task g(output st_e s2);
  endclass
  task c::f(output st_e s1);
    begin
      op_t rw;
      rw.a = 1;
      s1 = rw.status;
    end
  endtask
  task c::g(output st_e s2);
    s2 = OK;
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
