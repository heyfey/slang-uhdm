// § genPathExprSelSpan255 (an expression middle select then a literal leaf)
package hp;
  typedef struct packed { logic [31:0] d; logic [1:0][3:0] m; } key_t;
  typedef struct packed { key_t [7:0] key; logic [7:0][1:0] w; } hw2reg_t;
endpackage
module hmac #(parameter int N = 8) (output hp::hw2reg_t hw2reg);
  localparam int idx [8] = '{7,6,5,4,3,2,1,0};
  for (genvar i = 0; i < 8; i++) begin : gen_key_digest
    assign hw2reg.key[7-i].m[1] = '0;
  end
endmodule
module top;
  hp::hw2reg_t h;
  hmac u (.hw2reg(h));
endmodule
