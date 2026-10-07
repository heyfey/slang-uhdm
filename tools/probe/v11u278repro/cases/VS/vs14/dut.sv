// § trailIdxVarSelNamesByPath278
module top(output logic o, input logic [1:0][3:0] m);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  function automatic logic [4:0] g(logic x); return {4'b0, x}; endfunction
  always_comb o = q.f[g(m[1][2])];
endmodule
