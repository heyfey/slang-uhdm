// § nonTrailSelNestedSelWhole306
typedef struct packed { logic [3:0] k; logic [3:0] j; logic [3:0][3:0] idx; } t_t;
typedef struct packed { logic [7:0] f; logic [3:0][7:0] g; } e_t;
module top(input logic [1:0] i, output logic [7:0] r [2]);
  e_t sa [4]; logic [1:0] m [4];
  for (genvar gg = 0; gg < 2; gg++) begin : gb
    assign r[gg] = sa[m[m[gg]]].f;
  end
endmodule
