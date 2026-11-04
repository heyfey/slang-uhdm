// § constPathBaseAnyKind146
package p;
  typedef struct { int unsigned CTL; int unsigned DAT; } bus_t;
  localparam bus_t B = '{CTL:2, DAT:8};
  typedef struct packed {
    logic [B.CTL-1:0] ctl;
    logic [B.DAT-1:0] wdt;
  } req_t;
endpackage
module top(input p::req_t r, output logic [7:0] o);
  assign o = r.wdt;
endmodule
