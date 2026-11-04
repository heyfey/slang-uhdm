// § nonTrailIdxNamesByChain308
typedef struct packed { logic [3:0] k; logic [3:0] j; logic [3:0][3:0] idx; } t_t;
typedef struct packed { logic [3:0] k; t_t [1:0] a; } u_t;
typedef struct packed { logic [7:0] f; logic [3:0][7:0] g; } e_t;
module top(input logic clk, input logic [3:0] i, input logic [3:0] j, output logic [7:0] r);
  e_t sa [16]; t_t t; u_t u; logic [3:0] m[16]; logic [3:0] m2[4][4]; logic [7:0] v8;
  for (genvar a = 0; a < 2; a++) begin : ga
    for (genvar b = 0; b < 2; b++) begin : gb
      wire [7:0] w; assign w = sa[a + b + i].f;
    end
  end
  assign r = ga[0].gb[1].w;
endmodule
