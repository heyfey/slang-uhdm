// § trailIdxVarSelNamesByPath278
module top(output logic o, input logic [1:0][7:0] m);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  assign o = q.f[m[1][4:0]];
endmodule
