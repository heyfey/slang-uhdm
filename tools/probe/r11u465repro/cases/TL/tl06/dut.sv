// § pkgTransImpAggTd465
// the outer package is imported at $unit, a module reads the transitive enum through its own import
package types_pkg;
  typedef enum logic [2:0] {NUL, RD, WR} resp_e;
endpackage
package agent_pkg;
  import types_pkg::*;
endpackage
package env_pkg;
  import agent_pkg::*;
endpackage
import env_pkg::*;
module top;
  import types_pkg::*;
  resp_e r;
endmodule
