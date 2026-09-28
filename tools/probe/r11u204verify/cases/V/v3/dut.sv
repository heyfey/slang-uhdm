// § callArgVarSelStamp198 § vsStampReducedCtxOnly198v: genvar-indexed and three-index select actuals in a nested for-generate, under $unsigned and under $countones
module top (input logic [3:0] p [2][2], input logic [3:0] q [2][2][3], output logic [3:0] y [2][2], output logic [3:0] z [2][2]);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  for (genvar i = 0; i < 2; i++) begin : gi
    for (genvar j = 0; j < 2; j++) begin : gj
      assign y[i][j] = $unsigned(f(p[i][j]));
      assign z[i][j] = $countones(f(q[i][j][2]));
    end
  end
endmodule
