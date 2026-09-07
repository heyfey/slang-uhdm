// v196 arm X3 — a MODULE-HEADER import in a file that also carries a
// file-scope import of a DIFFERENT package.  The header item must count ONCE
// and the file item TWICE; nothing may be double-counted.
import masonPkg::*;
module xHdr import quarryPkg::*; (input int a, output int b);
  parameter int X3_OWN = 3;
  assign b = a + quarryTake(1) + masonTake(2) + X3_OWN;
endmodule
