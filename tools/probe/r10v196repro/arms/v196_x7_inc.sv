// v196 arm X7 — the module is written in the INCLUDER; the import arrives
// through `include.  Which buffer does the import item belong to?
`include "v196_x7_hdr.svh"
module xInc(input int a, output int b);
  assign b = a + quarryTake(5);
endmodule
