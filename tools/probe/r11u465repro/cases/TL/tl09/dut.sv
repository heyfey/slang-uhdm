// § pkgTransImpAggTd465
// control: direct imports only, the law adds nothing
package types_pkg;
  typedef enum {IDLE, BUSY} op_e;
endpackage
package agent_pkg;
  import types_pkg::*;
endpackage
module top;
  import agent_pkg::*;
endmodule
