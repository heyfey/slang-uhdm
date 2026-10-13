// § nonTrailIdxPathNestShape306
typedef struct packed { logic [3:0] k; logic [3:0] j; } t_t;
typedef struct packed { logic [7:0] f; logic [7:0] g; } e_t;
module top(input logic [7:0] d, output e_t so [16]);
  t_t t;
  always_comb begin so = '{default:'0}; so[t.k].f = d; end
endmodule
