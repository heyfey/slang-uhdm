// § trailIdxVarSelNamesByPath278
`define IDX m[1][2]
module top(output logic o, input logic [1:0][3:0] m);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  always_comb o = q.f[`IDX];
endmodule
