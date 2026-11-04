// § pkgPatReadTsBindsTopTypedef192
package p;
  typedef struct { int unsigned CTL; int unsigned DAT; } bus_t;
  localparam bus_t B = '{CTL:2, DAT:8};
  typedef logic [B.CTL-1:0] ctl_t;
endpackage
module top import p::*; (input logic [B.DAT-1:0] i, output logic [B.DAT-1:0] o, output ctl_t c);
  assign o = i;
  assign c = i[B.CTL-1:0];
endmodule
