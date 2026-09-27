// § trailIdxSelNamesByPath187
module top(input logic [2:0] i, input logic [1:0] j, output logic o, output logic p, output logic q);
  typedef struct packed { logic [3:0][1:0] g; logic [7:0] f; } s_t;
  s_t s;
  always_comb begin
    o = s.f[i[1:0]];
    p = s.f[i[j]];
    q = s.f[i[0+:2]];
  end
endmodule
