// § sysArgUnaryConstSelToken140v
module top(input logic [7:0] a, input logic [31:0] y, output logic [7:0] o);
  typedef struct packed { logic [31:0] f; } s_t;
  s_t s;
  assign s = y;
  assign o = s.f[0 +: $bits(~a)];
endmodule
