// § hierSelMacroBoundPretty405
`define SEL(x) x.addr[3:0]
typedef struct packed { logic [15:0] addr; logic v; } pkt_s;
module top (input pkt_s p, output logic [3:0] o);
  assign o = `SEL(p);
endmodule
