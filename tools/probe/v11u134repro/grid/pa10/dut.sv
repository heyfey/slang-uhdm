// § typedefParentLastWriter134
typedef struct packed { logic [3:0] x; logic y; } u_t;
module zm(input logic c, output logic [3:0] o);
  u_t v;
  always_comb v = '{x: {4{c}}, y: c};
  assign o = v.x;
endmodule
module am(input logic c, output logic [3:0] o);
  u_t w;
  always_comb w = '{x: 4'h3, y: c};
  assign o = w.x;
endmodule
module top(input logic c, output logic [3:0] o1, o2);
  zm z(.c(c), .o(o1));
  am a(.c(c), .o(o2));
endmodule
