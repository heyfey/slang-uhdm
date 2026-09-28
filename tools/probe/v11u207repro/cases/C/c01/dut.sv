// § namedSlotFillerRootFile207: a named call with an unwritten formal in a package defined in an included header, called from a module in the root file, both views
`include "pkg.svh"
module top(output int o, output int q);
  import pk::*;
  assign o = f(.a(1), .c(4));
  initial q = g(2);
endmodule
