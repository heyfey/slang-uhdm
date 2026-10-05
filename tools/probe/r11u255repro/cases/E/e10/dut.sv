// § genPathExprSelSpan255 (outside a generate block: control)
package hp;
  typedef struct packed { logic [31:0] d; } key_t;
  typedef struct packed { key_t [7:0] key; } hw2reg_t;
endpackage
module hmac (output hp::hw2reg_t hw2reg);
  localparam int I = 2;
  assign hw2reg.key[7-I].d = '0;
endmodule
module top;
  hp::hw2reg_t h;
  hmac u (.hw2reg(h));
endmodule
