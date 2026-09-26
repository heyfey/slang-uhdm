typedef struct packed {
  logic [3:0] a;
  logic [3:0] b;
} s_t;
typedef s_t s2_t;
typedef union packed {
  s2_t        s;
  logic [7:0] r;
} u_t;
