// § trailIdxVarSelNamesByPath278
module top(output logic o, input logic [1:0][3:0] m, input logic [3:0] w);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  assign o = q.f[w[m[1][2]]];
endmodule
