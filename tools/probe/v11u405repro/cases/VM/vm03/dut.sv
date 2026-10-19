// § hierSelMacroBoundPretty405
`define AW 5
typedef struct packed { logic [15:0] addr; logic v; } pkt_s;
module top (input pkt_s p, output logic [4:0] o);
  always_comb o = p.addr[`AW*2-1:`AW];
endmodule
