// § trailIdxVarSelNamesByPath278
module top(output logic o, input logic [3:0] ua [0:1][0:1]);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  always_comb o = q.f[ua[1][0]];
endmodule
