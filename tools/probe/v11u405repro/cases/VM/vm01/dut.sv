// § hierSelMacroBoundPretty405
`define OFF 2
`define W 3
typedef struct packed { logic [15:0] addr; logic v; } pkt_s;
module top (input pkt_s p, output logic [2:0] o);
  assign o = p.addr[`OFF +: `W];
endmodule
