// § genPathExprSelSpan255 (a two-index middle select with an expression first index)
package hp;
  typedef struct packed { logic [31:0] d; } key_t;
  typedef struct packed { key_t [3:0][1:0] k2; } hw2reg_t;
endpackage
module hmac (output hp::hw2reg_t hw2reg);
  for (genvar i = 0; i < 4; i++) begin : g
    assign hw2reg.k2[3-i][1].d = '0;
    assign hw2reg.k2[i][3-3].d = '0;
  end
endmodule
module top;
  hp::hw2reg_t h;
  hmac u (.hw2reg(h));
endmodule
