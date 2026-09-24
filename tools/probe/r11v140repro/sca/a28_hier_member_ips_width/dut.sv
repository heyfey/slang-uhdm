// § sysArgUnaryConstSelToken140v
module top(input logic [7:0] a, input logic [31:0] y, output logic [7:0] o);
  typedef struct packed { logic [31:0] f; } s_t;
  s_t s;
  always_comb begin
    s = y;
    o = s.f[4 +: $bits(~a)];
  end
endmodule
