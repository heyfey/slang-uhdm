// § genPathExprSelSpan255 (an index with two operators)
package hp;
  typedef struct packed { logic [31:0] d; } key_t;
  typedef struct packed { key_t [7:0] key; logic [7:0] b; } hw2reg_t;
endpackage
module hmac (output hp::hw2reg_t hw2reg, input logic [31:0] x);
  localparam int N = 8;
  logic [31:0] r;
  for (genvar i = 0; i < N; i++) begin : gen_key_digest
    assign hw2reg.key[i+1-1].d = '0;
  end
endmodule
module top;
  hp::hw2reg_t h;
  hmac u (.hw2reg(h), .x(32'd1));
endmodule
