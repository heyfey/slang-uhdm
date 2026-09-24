// § pkgPatInPkgReadNoParent133r — residue R2 of r11u133 (decode grid, not landed)
package p;
  typedef struct { int unsigned CTL; int unsigned DAT; } bus_t;
  localparam bus_t B = '{CTL:2, DAT:8};
  typedef struct packed { logic [B.DAT-1:0] wdt; } req_t;
endpackage
module top import p::*; (input req_t r, output logic [7:0] o);
  assign o = r.wdt;
endmodule
