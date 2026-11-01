// § elemBitsByExprEvalSize460v § clsArrPatBasedLitElemW460 (packed struct, union and packed-array elements)
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
typedef union packed { logic [7:0] x; bit [7:0] y; } u_t;
class C;
  s_t sd[] = '{'h12, 'h34};
  u_t ud[] = '{'h56, 'h78};
  logic [1:0][3:0] pd[] = '{'h9a, 'hbc};
endclass
module top;
  u_t mu[2] = '{'h11, 'h22};
  logic [1:0][3:0] mp[2] = '{'h33, 'h44};
  initial begin C c; c = new; end
endmodule
