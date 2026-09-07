// v196 arm X9 — the SAME package imported by TWO file-scope items, plus an
// EXPLICIT file item for a FUNCTION (no parameter) and a wildcard import of a
// package with NO parameters at all.
import quarryPkg::*;
import quarryPkg::*;
import quarryPkg::quarryTake;
import emptyParamPkg::*;
module xDup(input int a, output int b);
  assign b = a + quarryTake(7) + emptyTake(1);
endmodule
