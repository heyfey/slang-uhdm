// § elemBitsByExprEvalSize460v § modArrPatBasedLitElemW460 (time, integer, enum and signed vector elements)
typedef enum logic [2:0] {E0, E1} e_t;
module top;
  time tf[2] = '{'h1, 'h2};
  time td[] = '{'h3, 'h4};
  integer gi[2] = '{'h5, 'h6};
  e_t ee[2] = '{e_t'('h1), E0};
  bit signed [5:0] bs[] = '{'h7, 'o3};
  longint li[$] = {'h9, 'ha};
endmodule
