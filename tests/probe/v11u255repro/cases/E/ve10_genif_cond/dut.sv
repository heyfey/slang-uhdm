// § genPathExprSelSpan255 (an expression select in a generate-if condition on a parameter struct)
package hp;
  typedef struct packed { logic [31:0] d; logic [1:0][3:0] m; } key_t;
  typedef struct packed { key_t [7:0] key; logic [7:0][1:0] w; } hw2reg_t;
endpackage
module hmac #(parameter hp::hw2reg_t P = '0) (output hp::hw2reg_t hw2reg);
  for (genvar i = 1; i < 3; i++) begin : g
    if (P.key[i-1].d == 0) begin : z
      assign hw2reg.key[i].d = '0;
    end
  end
endmodule
module top;
  hp::hw2reg_t h;
  hmac u (.hw2reg(h));
endmodule
