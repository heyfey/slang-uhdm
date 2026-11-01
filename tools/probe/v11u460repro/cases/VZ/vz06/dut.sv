// § modArrPatBasedLitElemW460 (packed struct element)
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module top;
  s_t arr[2] = '{'h12, 'h34};
endmodule
