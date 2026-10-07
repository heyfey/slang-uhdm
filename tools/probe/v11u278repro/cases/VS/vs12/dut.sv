// § trailIdxVarSelNamesByPath278
module top(output logic [3:0] o, input logic [1:0][3:0] m);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  always_comb begin
    o = '0;
    for (int k = 0; k < 4; k++) o[k] = q.f[m[1][k]];
  end
endmodule
