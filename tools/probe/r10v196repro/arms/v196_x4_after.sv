// v196 arm X4 — the file-scope import written AFTER the module it must reach.
module xAfter(input int a, output int b);
  assign b = a + 1;
endmodule
import quarryPkg::*;
module xAfterTwo(input int a, output int b);
  assign b = a + quarryTake(2);
endmodule
