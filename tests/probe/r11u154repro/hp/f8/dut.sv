// § hpPartSelBoundNamesBySelect154
module top(input logic clk, output logic [3:0] o);
  localparam int GW = 4;
  typedef struct packed { logic [7:0] wdt; } s_t;
  s_t s;
  always_ff @(posedge clk) o <= s.wdt[GW-1:0];
endmodule
