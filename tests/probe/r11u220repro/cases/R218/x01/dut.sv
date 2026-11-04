// § hpTrailIpsNamesByPath218
module top(input logic [31:0] d, output logic [7:0] o [4]);
  typedef struct packed { logic [31:0] d; } s_t;
  s_t s;
  assign s.d = d;
  for (genvar k = 0; k < 4; k++) begin : g
    assign o[k] = s.d[k*8 +: 8];
  end
endmodule
