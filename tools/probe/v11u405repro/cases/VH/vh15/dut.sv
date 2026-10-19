// § hierSelWidthLocalKeep405
typedef struct packed { logic [15:0] addr; logic v; } pkt_s;
module top (input pkt_s p, output logic [2:0] o);
  localparam l = 3;
  generate
    wire [2:0] w = p.addr[0 +: l];
  endgenerate
  assign o = w;
endmodule
