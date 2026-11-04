// § hierSelWidthLocalKeep405
typedef struct packed { logic [15:0] addr; logic v; } pkt_s;
module top (input pkt_s p, output logic [7:0] o);
  localparam l = 3;
  if (1) begin : g
    assign o = p.addr[15 -: l];
  end
endmodule
