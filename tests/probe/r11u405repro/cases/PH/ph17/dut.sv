// § hierSelWidthLocalKeep405
typedef struct packed { logic [15:0] addr; logic v; } pkt_s;
module top #(parameter k = 3) (input pkt_s p, output logic [7:0] o);
  localparam l = 3;
  assign o = p.addr[k +: l];
endmodule
