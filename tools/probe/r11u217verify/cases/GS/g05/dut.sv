// § genConnTrailSelChain205 — r11u217 g05: a three-level nested member path `c.s.en[k]`, a 2-bit slice select `c.m[k]` of a two-dimensional packed member, an output port actual `.y(r.en[k])`, and a generate loop inside an INTERFACE instantiating interfaces
typedef struct packed { logic [3:0] en; } in_t;
typedef struct packed { in_t s; logic [3:0][1:0] m; } cfg_t;
interface pi (input logic c);
  logic w;
  assign w = c;
endinterface
module leaf (input logic x, output logic y);
  assign y = x;
endmodule
module leaf2 (input logic [1:0] x, output logic [1:0] y);
  assign y = x;
endmodule
interface gi (input cfg_t c);
  for (genvar k = 0; k < 4; k++) begin : gg
    pi u (.c(c.s.en[k]));
  end
endinterface
module top (input cfg_t c, output logic [3:0] o, output logic [7:0] p, output in_t r);
  gi g (.c(c));
  assign o[0] = g.gg[0].u.w;
  assign o[3:1] = 3'b0;
  for (genvar k = 0; k < 4; k++) begin : gl
    leaf2 u (.x(c.m[k]), .y(p[k*2 +: 2]));
    leaf v (.x(c.s.en[k]), .y(r.en[k]));
  end
endmodule
