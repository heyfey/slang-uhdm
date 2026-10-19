// § hierSelWidthLocalKeep405
typedef struct packed { logic [15:0] addr; logic v; } pkt_s;
module top (input pkt_s p, output logic [2:0] o);
  localparam l = 3;
  logic [2:0] w = p.addr[0 +: l], x = p.addr[3 +: l];
  var logic [2:0] y = p.addr[6 +: l];
  assign o = w ^ x ^ y;
endmodule
