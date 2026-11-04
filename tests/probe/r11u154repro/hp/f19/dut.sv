// § hpPartSelBoundNamesBySelect154
module top(input logic [7:0] i, output logic [3:0] o);
  localparam int GW = 4;
  typedef struct packed { logic [7:0] wdt; } s_t;
  typedef struct packed { s_t in; } t_t;
  t_t v;
  assign v = i;
  assign o = v.in.wdt[GW-1:0];
endmodule
