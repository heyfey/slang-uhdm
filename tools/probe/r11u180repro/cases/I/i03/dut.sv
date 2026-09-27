// § ifaceWildcardTdNameOrder180
package q;
  typedef logic [2:0] b_t;
  typedef logic [1:0] a_t;
endpackage
package p;
  typedef struct packed { logic [3:0] rdt; logic sts; } rsp_t;
  typedef struct packed { logic ren; logic [3:0] adr; } req_t;
endpackage
interface bus_if;
  import p::*;
  import q::*;
  req_t req;
  rsp_t rsp;
  a_t a; b_t b;
endinterface
module top (output logic [3:0] o);
  bus_if b();
  assign o = b.rsp.rdt;
endmodule
