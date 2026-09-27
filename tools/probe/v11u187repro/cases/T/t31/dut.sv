// § trailIdxSelNamesByPath187 (indexed part select and nested bit select in an lvalue)
module top(input logic [2:0] i, input logic [1:0] j, input int k);
  typedef struct packed { logic [7:0] f; } s_t;
  s_t s;
  int a[4];
  always_comb begin
    s.f[i[j]] = 1'b1;
    s.f[i[0+:2]] = 1'b0;
    s.f[a[k]] = 1'b1;
  end
endmodule
