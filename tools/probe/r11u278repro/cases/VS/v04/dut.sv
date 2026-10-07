// § trailIdxVarSelNamesByPath278
module top(output logic o, input logic [3:0] m [0:1][0:1]);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  assign o = q.f[{1'b1, m[1][0]}];
endmodule
