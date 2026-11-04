// § trailIdxVarSelNamesByPath278
module top(output logic o, input logic [1:0][3:0] m);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  function automatic logic [1:0] g(logic [1:0] x); return x; endfunction
  always_comb o = q.f[m[g(2'd1)][2]];
endmodule
