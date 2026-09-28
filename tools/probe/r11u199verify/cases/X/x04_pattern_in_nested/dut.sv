// § pkgPatReadTsBindsTopTypedef192 § nestedDefChainName193
package p;
  typedef struct { int unsigned CTL; int unsigned DAT; } bus_t;
  localparam bus_t B = '{CTL:2, DAT:6};
  typedef logic [B.CTL-1:0] ctl_t;
endpackage
module sub import p::*; (input ctl_t c);
  module inner (input ctl_t s, output logic [B.DAT-1:0] q);
    localparam bus_t L = '{CTL:B.CTL, DAT:B.DAT};
    assign q = {{(L.DAT-L.CTL){1'b0}}, s};
  endmodule
  ctl_t r;
  assign r = c;
endmodule
module dut import p::*; (input ctl_t c, output ctl_t o);
  sub u_s (.c(c));
  assign o = c;
endmodule
