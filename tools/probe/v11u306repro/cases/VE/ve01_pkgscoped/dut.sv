// § nonTrailIdxPathNestShape306
package pk;
  typedef struct packed { logic [7:0] f; } e_t;
  e_t parr [16];
endpackage
typedef struct packed { logic [3:0] k; } t_t;
module top(input t_t t, output logic [7:0] r);
  assign r = pk::parr[t.k].f;
endmodule
