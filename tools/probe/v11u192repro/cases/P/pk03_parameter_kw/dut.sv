// § pkgPatReadTsBindsTopTypedef192
package p;
  typedef struct { int unsigned CTL; int unsigned DAT; } bus_t;
  parameter bus_t B = '{CTL:2, DAT:8};
  typedef struct packed { logic [B.CTL-1:0] ctl; logic [B.DAT-1:0] wdt; } req_t;
endpackage
module top (input logic [9:0] i, output logic [9:0] o);
  p::req_t r;
  assign r = i;
  assign o = r;
endmodule
