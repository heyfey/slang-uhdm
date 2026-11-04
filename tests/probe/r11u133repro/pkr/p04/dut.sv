// § pkgPatInPkgReadNoParent133r — residue R2 of r11u133 (decode grid, not landed)
package p;
  typedef struct packed { logic [7:0] CTL; logic [7:0] DAT; } bus_t;
  localparam bus_t B = '{CTL:2, DAT:8};
endpackage
module top (output logic [7:0] o);
  assign o = 8'd1;
endmodule
