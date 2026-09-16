// r11u34 grid u1 — an UNPACKED-struct package localparam with an
// all-constant named pattern, in three reader faces.
package p;
  typedef struct { int unsigned CTL; int unsigned DAT; int unsigned STS; } bus_t;
  localparam bus_t BSEL = '{CTL:0, DAT:8, STS:0};   // member-selected in-package
  localparam bus_t BSCP = '{CTL:1, DAT:9, STS:1};   // read as p::BSCP outside
  localparam bus_t BNON = '{CTL:2, DAT:7, STS:2};   // never read
  typedef struct packed { logic [BSEL.DAT-1:0] w; } req_t;
endpackage
module u1 (output logic [31:0] o);
  p::req_t r;
  assign o = p::BSCP.DAT + r.w;
endmodule
