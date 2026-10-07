// § trailIdxVarSelNamesByPath278
module top(output logic o, input logic [1:0][3:0] m);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  function automatic int f2(int a); return a; endfunction
  always_comb o = q.f[m[f2(1)][2]];
endmodule
