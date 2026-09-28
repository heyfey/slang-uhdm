// § pkgPatReadTsBindsTopTypedef192
package p;
  typedef struct { int unsigned W; } in_t;
  typedef struct { in_t A; int unsigned DAT; } bus_t;
  localparam bus_t B = '{A:'{W:3}, DAT:8};
  typedef logic [B.DAT-1:0] dat_t;
endpackage
module top import p::*; (input dat_t i, output dat_t o);
  assign o = i;
endmodule
