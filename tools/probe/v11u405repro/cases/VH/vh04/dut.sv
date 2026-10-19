// § hierSelWidthLocalKeep405
typedef struct packed { logic [15:0] addr; logic v; } pkt_s;
module top (input pkt_s p, output logic [7:0] o);
  if (1) begin : g
    localparam l = 4;
    assign o = p.addr[1 +: l];
  end
endmodule
