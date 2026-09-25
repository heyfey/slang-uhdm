// § hpPartSelBoundNamesBySelect154
module top(input logic [15:0] x, output logic [3:0] o);
  localparam int GW = 4;
  typedef struct packed { logic [7:0] a; logic [7:0] wdt; } s_t;
  s_t s;
  assign s = x;
  generate if (1) begin : g
    assign o = s.wdt[GW-1:0];
  end endgenerate
endmodule
