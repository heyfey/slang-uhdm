// § genPathExprSelSpan255 (the index written by a macro)
`define REV(a) (7-(a))
package hp;
  typedef struct packed { logic [31:0] d; logic [1:0][3:0] m; } key_t;
  typedef struct packed { key_t [7:0] key; logic [7:0][1:0] w; } hw2reg_t;
endpackage
module hmac (output hp::hw2reg_t hw2reg);
  for (genvar i = 0; i < 8; i++) begin : g
    assign hw2reg.key[`REV(i)].d = '0;
  end
endmodule
module top;
  hp::hw2reg_t h;
  hmac u (.hw2reg(h));
endmodule
