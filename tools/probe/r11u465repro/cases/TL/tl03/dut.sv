// § pkgTransImpAggTd465
// env imports types directly first, then agent: each typedef listed once
package types_pkg;
  typedef enum logic [1:0] {R0, R1} resp_e;
  typedef struct packed { logic a; resp_e r; } it_s;
endpackage
package agent_pkg;
  import types_pkg::*;
endpackage
package env_pkg;
  import types_pkg::*;
  import agent_pkg::*;
endpackage
module top;
  import env_pkg::*;
endmodule
