// § namedSlotFillerRootFile207 (a package from an included header: resolved named calls skipping formals)
`include "pk.svh"
module top (input int x, output int o);
  assign o = pk::useit(x);
endmodule
