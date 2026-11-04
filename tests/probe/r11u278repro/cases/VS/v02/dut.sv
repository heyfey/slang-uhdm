// § trailIdxVarSelNamesByPath278
module top(output logic o, input logic [1:0][3:0] m, input logic [1:0] k);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  always_comb o = q.f[m[k][2]];
endmodule
