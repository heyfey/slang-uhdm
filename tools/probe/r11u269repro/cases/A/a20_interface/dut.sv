// § topNestedArrElemTopTwin269 (an interface port of the struct type and a module reading through it)
package p;
  typedef struct packed { logic [3:0] q; } addr_t;
  typedef struct packed {
    struct packed { logic q; } en;
    struct packed { logic [3:0] q; } base;
  } mreg_t;
  typedef struct packed { addr_t addr; mreg_t [1:0] cfg; } reg2hw_t;
endpackage
interface bus_if;
  import p::*;
  reg2hw_t r;
endinterface
module sub(input logic d, output logic q); assign q = d; endmodule
module regtop(bus_if b, input logic d);
  import p::*;
  sub u0(.d(d), .q(b.r.cfg[0].en.q));
endmodule
module top(input logic d);
  bus_if b();
  regtop u_reg(.b(b), .d(d));
endmodule
