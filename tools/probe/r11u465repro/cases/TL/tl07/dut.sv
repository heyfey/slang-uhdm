// § pkgTransImpAggTd465
// an enum-alias typedef in the third package
package types_pkg;
  typedef enum {A0, A1} base_e;
  typedef base_e alias_e;
endpackage
package agent_pkg;
  import types_pkg::*;
endpackage
package env_pkg;
  import agent_pkg::*;
endpackage
module top;
  import env_pkg::*;
endmodule
