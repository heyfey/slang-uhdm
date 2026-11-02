// § pkgTransImpAggTd465
// the middle package imports one typedef explicitly: the walk follows wildcard items only
package types_pkg;
  typedef enum logic [1:0] {R0, R1} resp_e;
  typedef struct packed { logic a; } it_s;
endpackage
package agent_pkg;
  import types_pkg::resp_e;
  resp_e r;
endpackage
package env_pkg;
  import agent_pkg::*;
endpackage
module top;
  import env_pkg::*;
endmodule
