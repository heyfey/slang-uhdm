// v196 arm X11 — a NESTED module declaration inside a module, in a file with a
// file-scope import (the parent scope is not a CompilationUnit).
import quarryPkg::*;
module xOuter(input int a, output int b);
  module xInner(input int c, output int d);
    assign d = c + quarryTake(9);
  endmodule
  xInner u0(a, b);
endmodule
