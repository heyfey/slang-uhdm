// § ifaceWildcardTdNameOrder180
package p;
  typedef enum logic [1:0] { Z0, Z1 } z_t;
  typedef struct packed { logic [3:0] rdt; logic sts; } rsp_t;
  typedef enum logic { A0, A1 } a_t;
endpackage
interface bus_if;
  import p::*;
  rsp_t rsp;
  z_t z; a_t a;
endinterface
module top (output logic [3:0] o);
  bus_if b();
  assign o = b.rsp.rdt;
endmodule
