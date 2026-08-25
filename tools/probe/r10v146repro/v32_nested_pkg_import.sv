// A $unit import PLUS a nested-module and a generate-scope home for the
// references, three instances of a leaf, and two tops.
package pv32;
  parameter int K = 32;
  parameter int J = 33;
endpackage
import pv32::*;
module leaf_v32 (output int o);
  assign o = K;
endmodule
module mid_v32;
  int w [0:2];
  genvar g;
  generate
    for (g = 0; g < 3; g++) begin : gg
      leaf_v32 u (.o(w[g]));
    end
  endgenerate
endmodule
module top_v32a;
  mid_v32 m0();
  int z;
  initial z = J;
endmodule
module top_v32b;
  int z;
  initial z = K + J;
endmodule
