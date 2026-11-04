// § hierSelWidthLocalKeep405
module top; endmodule
module m #(parameter n, parameter k = 3) (input logic [15:0] i, output logic [7:0] o);
  typedef struct packed { logic [15:0] addr; logic v; } pkt_s;
  pkt_s p;
  assign p = '{addr: i, v: 1'b1};
  localparam l = (n == 1) ? 1 : $clog2(n);
  assign o = p.addr[k +: l];
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
