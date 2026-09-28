// § callArgInSelIdxChainName201
typedef struct { logic [3:0] f[4]; } s_t;
module top(output logic [3:0] y);
  function automatic int fx(logic [3:0] v); return v & 3; endfunction
  s_t s, t;
  int k;
  for (genvar g = 0; g < 2; g++) begin : gb
    logic [3:0] r;
    assign r = t.f[fx(s.f[g])];
  end
  assign y = t.f[fx(s.f[k])];
endmodule
