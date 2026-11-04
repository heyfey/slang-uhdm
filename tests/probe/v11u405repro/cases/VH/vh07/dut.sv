// § hierSelWidthLocalKeep405
typedef struct packed { logic [15:0] addr; logic v; } pkt_s;
module top (input pkt_s p, output logic [2:0] o);
  localparam l = 3;
  always_comb begin
    logic [2:0] w = p.addr[1 +: l];
    o = w;
  end
endmodule
