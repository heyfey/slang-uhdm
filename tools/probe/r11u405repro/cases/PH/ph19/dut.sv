// § hierSelWidthLocalKeep405
typedef struct packed { logic [15:0] addr; logic v; } pkt_s;
module top (input pkt_s p, output logic [7:0] o);
  localparam l = 3;
  always_comb o = p.addr[0 +: l];
endmodule
