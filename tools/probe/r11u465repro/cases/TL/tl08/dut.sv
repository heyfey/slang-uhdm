// § pkgTransImpAggTd465
// two outer packages import the same middle package: the last lister owns the clone
package types_pkg;
  typedef struct packed { logic [3:0] a; } it_s;
endpackage
package agent_pkg;
  import types_pkg::*;
endpackage
package env1_pkg;
  import agent_pkg::*;
endpackage
package env2_pkg;
  import agent_pkg::*;
endpackage
module top;
  import env1_pkg::*;
  import env2_pkg::*;
endmodule
