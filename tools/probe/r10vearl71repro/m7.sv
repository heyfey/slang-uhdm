package pm7_v71;
  parameter int B7 = 8'b1010_0001;
endpackage
module lm7_v71 (input [4095:0] x);
endmodule
module m7 import pm7_v71::*; (input [4095:0] sig);
  for (genvar g = 0; g < 1; g++) begin: gm
    lm7_v71 i0 (.x(sig[4095:B7]));
  end
endmodule
