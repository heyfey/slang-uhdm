// § pkgPatReadTsBindsTopTypedef192
package p;
  typedef struct packed { logic [7:0] CTL; logic [7:0] DAT; } bus_t;
  localparam bus_t B = '{CTL:1, DAT:8};
  typedef struct packed { logic [B.CTL-1:0] ctl; logic [B.DAT-1:0] wdt; } req_t;
endpackage
module top import p::*; (input logic [8:0] i, output logic [8:0] o);
  req_t r;
  assign r = i;
  assign o = r;
endmodule
