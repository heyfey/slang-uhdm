// § ifaceWildcardTdNameOrder180
package p;
  typedef struct packed { logic [3:0] rdt; logic sts; } rsp_t;
  typedef struct packed { logic ren; logic [3:0] adr; } req_t;
endpackage
interface bus_if;
  import p::*;
  req_t req;
  rsp_t rsp;
endinterface
module top (output logic [3:0] o);
  bus_if b();
  assign o = b.rsp.rdt;
endmodule
