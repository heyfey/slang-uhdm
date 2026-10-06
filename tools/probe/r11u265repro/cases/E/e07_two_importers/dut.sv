// § cloneSharedAggOwnCopy265 (two importer packages each copying the method)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { int a; st_e status; } op_t;
  class c;
    extern task f(output st_e s1);
  endclass
  task c::f(output st_e s1);
    begin
      op_t rw;
      s1 = rw.status;
    end
  endtask
  task g(input st_e s2);
  endtask
endpackage
package q;
  import p::*;
endpackage
package q2;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
