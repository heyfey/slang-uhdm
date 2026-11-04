// § aliasCloneTakesTargetFile137
// case al07: the alias typedef sits in an included file, its struct target in dut.sv
package ai;
  typedef struct packed { logic k; } a;
`include "alias.svh"
endpackage
module top();
  ai::b v;
endmodule
