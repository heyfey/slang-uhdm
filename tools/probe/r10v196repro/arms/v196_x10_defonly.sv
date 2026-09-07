// v196 arm X10 — a module that is only ever instantiated inside a NON-TAKEN
// generate branch (the § detachedInstNoConns face), in a file that carries a
// file-scope import.
import quarryPkg::*;
module xNever(input int a, output int b);
  assign b = a + quarryTake(8);
endmodule
module xGenTop(input int a, output int b);
  parameter int TAKE = 0;
  generate
    if (TAKE) begin : g_yes
      xNever u0(a, b);
    end
    else begin : g_no
      assign b = a;
    end
  endgenerate
endmodule
