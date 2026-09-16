// r11u49 arm a1 — UNPACKED vs PACKED struct package localparams, same reader
// faces, side by side.  The PACKED half is the landed law's own witness and
// must not move; the UNPACKED half is this pass's target.
package p;
  typedef struct        { int unsigned CTL; int unsigned DAT; int unsigned STS; } ubus_t;
  typedef struct packed { logic [7:0] CTL; logic [7:0] DAT; logic [7:0] STS; }    pbus_t;
  localparam ubus_t USEL = '{CTL:0, DAT:8, STS:0};   // member-selected in-package
  localparam ubus_t USCP = '{CTL:1, DAT:9, STS:1};   // read as p::USCP outside
  localparam ubus_t UNON = '{CTL:2, DAT:7, STS:2};   // never read
  localparam pbus_t PSEL = '{CTL:0, DAT:8, STS:0};
  localparam pbus_t PSCP = '{CTL:1, DAT:9, STS:1};
  localparam pbus_t PNON = '{CTL:2, DAT:7, STS:2};
  typedef struct packed { logic [USEL.DAT-1:0] w; logic [PSEL.DAT-1:0] v; } req_t;
endpackage
module a1 (output logic [31:0] o);
  p::req_t r;
  assign o = p::USCP.DAT + p::PSCP.DAT + r.w + r.v;
endmodule
