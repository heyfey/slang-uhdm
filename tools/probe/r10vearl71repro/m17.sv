package pm_v71;
  parameter int B17 = 20 + 8'd4;
endpackage
module lm_v71 (input [63:0] x);
endmodule
module m17 import pm_v71::*; (input [63:0] sig);
  for (genvar g = 0; g < 1; g++) begin: gm
    lm_v71 i0 (.x(sig[63:B17]));
  end
endmodule
