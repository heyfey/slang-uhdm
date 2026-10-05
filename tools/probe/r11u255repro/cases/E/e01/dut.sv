// § genPathExprSelSpan255 (the decode of Earlgrey #142988: key[7-i])
package hp;
  typedef struct packed { logic [31:0] d; } key_t;
  typedef struct packed { key_t [7:0] key; } hw2reg_t;
endpackage
module hmac (output hp::hw2reg_t hw2reg);
  for (genvar i = 0; i < 8; i++) begin : gen_key_digest
    assign hw2reg.key[7-i].d      = '0;
  end
endmodule
module top;
  hp::hw2reg_t h;
  hmac u (.hw2reg(h));
endmodule
