// § hierSelWidthLocalKeep405
typedef struct packed { logic [15:0] addr; logic v; } pkt_s;
module s(input logic [2:0] a, output logic [2:0] b); assign b = a; endmodule
module m (input pkt_s p, output logic [2:0] o);
  localparam l = 3;
  s u(.a(p.addr[0 +: l]), .b(o));
endmodule
module top (input pkt_s p, output logic [2:0] o);
  m u(p, o);
endmodule
