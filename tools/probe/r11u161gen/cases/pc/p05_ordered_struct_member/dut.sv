// r11u161 port face (R5): ordered connections to struct-variable members, input and output
module leaf (input logic [3:0] i, output logic [3:0] y);
  assign y = ~i;
endmodule
module top (input logic [3:0] s, output logic [7:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } st_t;
  st_t v;
  assign v.a = s;
  leaf u0 (v.a, v.b);
  assign o = v;
endmodule
