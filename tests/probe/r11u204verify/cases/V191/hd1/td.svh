  typedef struct packed { logic [1:0] a; logic [1:0] b; } op_t;
  typedef union packed { logic [3:0] w; op_t o; } uo_t;
