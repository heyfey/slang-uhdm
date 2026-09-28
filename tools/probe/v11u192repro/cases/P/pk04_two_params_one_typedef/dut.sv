// § pkgPatReadTsBindsTopTypedef192
package p;
  typedef struct { int unsigned CTL; int unsigned DAT; } bus_t;
  localparam bus_t B = '{CTL:1, DAT:8};
  localparam bus_t D = '{CTL:3, DAT:4};
  typedef struct packed { logic [B.CTL-1:0] ctl; logic [D.DAT-1:0] wdt; logic [D.CTL-1:0] x; } req_t;
endpackage
module top import p::*; (input logic [7:0] i, output logic [7:0] o);
  req_t r;
  assign r = i;
  assign o = r;
endmodule
