// § hierSelMacroBoundPretty405
`define HI (N-1)
typedef struct packed { logic [15:0] addr; logic v; } pkt_s;
module top #(parameter N = 4) (input pkt_s p, output logic [3:0] o);
  assign o = p.addr[`HI:0];
endmodule
