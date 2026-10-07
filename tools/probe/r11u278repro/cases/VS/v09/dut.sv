// § trailIdxVarSelNamesByPath278
module top(input logic d, input logic [1:0][3:0] m);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  always_comb q.f[m[1][2]] = d;
endmodule
