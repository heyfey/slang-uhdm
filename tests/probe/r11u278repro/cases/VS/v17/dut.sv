// § trailIdxVarSelNamesByPath278
module top(output logic [3:0] o, input logic [1:0][3:0] m);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar j = 0; j < 2; j++) begin : h
      always_comb o[2*i+j] = q.f[m[i][j]];
    end
  end
endmodule
