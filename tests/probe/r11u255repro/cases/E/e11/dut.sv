// § genPathExprSelSpan255 (a generate-if body)
package hp;
  typedef struct packed { logic [31:0] d; } key_t;
  typedef struct packed { key_t [7:0] key; } hw2reg_t;
endpackage
module hmac #(parameter int P = 1) (output hp::hw2reg_t hw2reg);
  if (P > 0) begin : g_on
    assign hw2reg.key[1+1].d = '0;
  end
endmodule
module top;
  hp::hw2reg_t h;
  hmac u (.hw2reg(h));
endmodule
