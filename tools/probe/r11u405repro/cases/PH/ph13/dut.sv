// § hierSelWidthLocalKeep405
module top #(parameter n = 8, parameter k = 3) (input logic [15:0] i, output logic [7:0] o);
  typedef struct packed { logic [15:0] addr; logic v; } pkt_s;
  pkt_s p;
  assign p = '{addr: i, v: 1'b1};
  localparam l = (n == 1) ? 1 : 3;
  assign o = p.addr[k +: l];
endmodule
