// § defGenConnSelAtIndex416
module sub(input logic [1:0] a, output logic o);
  assign o = a[0];
endmodule
module top(input logic [3:0] y, output logic [3:0] z);
  typedef struct packed { logic [3:0] f; } s_t;
  s_t s;
  assign s.f = y;
  for (genvar i = 0; i < 4; i++) begin : g
    sub u (.a({s.f[i], y[i]}), .o(z[i]));
  end
endmodule
