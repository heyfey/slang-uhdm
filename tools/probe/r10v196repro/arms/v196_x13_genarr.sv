// v196 arm X13 — a GENERATE-LOOP INSTANCE ARRAY of a module written in a file
// that carries a file-scope import (the R2 arity face).
import quarryPkg::*;
module xCell(input int a, output int b);
  assign b = a + quarryTake(1);
endmodule
module xArrTop(input int a, output int b);
  int w[0:4];
  assign w[0] = a;
  generate
    for (genvar i = 0; i < 4; i++) begin : g_loop
      xCell u(w[i], w[i+1]);
    end
  endgenerate
  assign b = w[4];
endmodule
