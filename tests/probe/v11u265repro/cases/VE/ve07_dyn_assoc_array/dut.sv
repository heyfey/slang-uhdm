// § cloneSharedAggOwnCopy265 (fresh: the array leg on a dynamic and an associative array local)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { int a; st_e status; } op_t;
  class c;
    extern task f(output st_e s1);
  endclass
  task c::f(output st_e s1);
    begin
      op_t d[];
      op_t m[int];
      d = new[2];
      s1 = d[0].status;
      s1 = m[3].status;
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
