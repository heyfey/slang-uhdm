// § trailIdxVarSelNamesByPath278
module top(output logic o, input logic [1:0][3:0] m);
  typedef struct packed {logic [31:0] f;} st_t;
  typedef struct packed {logic [31:0] g;} rt_t;
  st_t q; rt_t r;
  always_comb o = q.f[r.g[m[1][2]]];
endmodule
