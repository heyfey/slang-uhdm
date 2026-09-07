// v196 arm X5 — an INTERFACE defined in a file with a file-scope import and
// INSTANTIATED, plus a module that uses it.
import quarryPkg::*;
interface xIf(input int a);
  int r;
endinterface
module xIfTop(input int a, output int b);
  xIf u_if(a);
  assign b = a + quarryTake(3);
endmodule
