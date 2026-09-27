// § ifaceWildcardTdNameOrder180 (r11u190: the interface declares its own req_t, shadowing the wildcard-imported one)
package p;
  typedef struct packed { logic [3:0] rdt; logic sts; } rsp_t;
  typedef struct packed { logic ren; logic [3:0] adr; } req_t;
endpackage
interface bus_if;
  import p::*;
  typedef struct packed { logic [7:0] wide; } req_t;
  req_t req;
  rsp_t rsp;
endinterface
module top(output logic [7:0] o);
  bus_if b();
  assign o = b.req.wide;
endmodule
