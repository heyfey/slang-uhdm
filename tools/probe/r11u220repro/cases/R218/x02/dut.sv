// § hpTrailIpsNamesByPath218
module sub(input logic [7:0] a); endmodule
module top(input logic [31:0] d);
  typedef struct packed { logic [31:0] d; } s_t;
  s_t s;
  localparam int OFF = 8;
  assign s.d = d;
  sub u(.a(s.d[OFF -: 8]));
endmodule
