// v196 arm X6 file A — the import and the DEFINITION live here.
import quarryPkg::*;
module xSixLeaf(input int a, output int b);
  assign b = a + quarryTake(4);
endmodule
