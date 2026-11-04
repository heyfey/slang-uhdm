`define FLD(n) logic [1:0] n``_f;
typedef struct packed {
  `FLD(a)
  `FLD(b)
} s_t;
