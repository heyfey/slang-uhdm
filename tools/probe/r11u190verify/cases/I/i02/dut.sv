// § ifaceWildcardTdNameOrder180 (r11u190: an explicit import and a wildcard import of the same package in one interface)
package p;
  typedef struct packed { logic [3:0] rdt; logic sts; } rsp_t;
  typedef struct packed { logic ren; logic [3:0] adr; } req_t;
  typedef struct packed { logic v; } cfg_t;
endpackage
interface bus_if;
  import p::rsp_t;
  import p::*;
  req_t req;
  rsp_t rsp;
  cfg_t cfg;
endinterface
module top(output logic [3:0] o);
  bus_if b();
  assign o = b.rsp.rdt;
endmodule
