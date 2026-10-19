// § aliasElemDynTd406
typedef struct packed { logic a; } s_t;
typedef s_t d_t [];
typedef enum {X, Y} e_t;
typedef e_t q_t [$];
module top;
  d_t d;
  q_t q;
endmodule
