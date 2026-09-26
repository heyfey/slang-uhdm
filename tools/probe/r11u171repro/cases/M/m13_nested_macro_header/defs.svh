`define W 4
`define M(n) logic [`W-1:0] n;
typedef struct packed {
  `M(a)
  logic b;
} s_t;
