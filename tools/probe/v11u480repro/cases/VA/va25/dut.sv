// § fixArrLocalNamedAggElemTs480 (package struct in an interface task exported through a modport)
package p;
  typedef struct { int k; int d; } op_t;
endpackage
interface ifc;
  import p::*;
  int r;
  task t(int n);
    op_t acc[2];
    acc[0].k = n;
    r = acc[0].k;
  endtask
  modport mp(import t);
endinterface
module user(ifc.mp b);
  initial b.t(4);
endmodule
module top;
  ifc u();
  user s(.b(u));
endmodule
