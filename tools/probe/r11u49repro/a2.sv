// r11u49 arm a2 — MODULE-scope (not package) unpacked-struct localparam with a
// named pattern, in both reader faces.  A module-LOCAL struct param flat-folds
// unconditionally on the landed packed road (no inPackage gate); does the
// unpacked one?
module a2 (output logic [31:0] o);
  typedef struct        { int unsigned CTL; int unsigned DAT; } ubus_t;
  typedef struct packed { logic [7:0] CTL; logic [7:0] DAT; } pbus_t;
  localparam ubus_t UM = '{CTL:3, DAT:4};
  localparam pbus_t PM = '{CTL:3, DAT:4};
  localparam ubus_t UN = '{CTL:5, DAT:6};   // never read
  assign o = UM.DAT + PM.DAT;
endmodule
