// § trailIdxVarSelNamesByPath278
module top(output logic o, input logic [1:0][3:0] m);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q [2];
  always_comb o = q[1].f[m[1][2]];
endmodule
