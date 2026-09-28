// § pkgPatReadTsBindsTopTypedef192
package p;
  typedef struct { int unsigned CTL; int unsigned DAT; } bus_t;
  localparam bus_t B = '{CTL:2, DAT:6};
  typedef logic [B.CTL-1:0] ctl_t;
  function automatic int unsigned width();
    return B.CTL + B.DAT;
  endfunction
endpackage
module top import p::*; (input ctl_t c, output logic [7:0] o, output int unsigned w);
  assign o = {6'b0, c};
  assign w = width();
endmodule
