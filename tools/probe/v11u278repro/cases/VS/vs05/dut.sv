// § trailIdxVarSelNamesByPath278
module top(output logic [1:0] o, input logic [1:0][3:0] m);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  always_comb o = q.f[m[1][2] +: 2];
endmodule
