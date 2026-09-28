// § pkgPatReadTsBindsTopTypedef192
package p;
  typedef struct { int unsigned CTL; int unsigned DAT; } bus_t;
  localparam bus_t B = '{CTL:1, DAT:8};
  typedef struct packed { logic [B.CTL-1:0] ctl; logic [B.DAT-1:0] wdt; } req_t;
endpackage
interface my_if import p::*; ();
  req_t req;
endinterface
module top import p::*; (input logic [8:0] i, output logic [8:0] o);
  my_if a ();
  assign a.req = i;
  assign o = a.req;
endmodule
