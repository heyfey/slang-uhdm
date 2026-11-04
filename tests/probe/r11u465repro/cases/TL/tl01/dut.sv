// § pkgTransImpAggTd465
// env imports agent, agent imports types: env lists types' enum, struct and vector typedefs
package types_pkg;
  typedef enum {IDLE, BUSY} op_e;
  typedef enum logic [1:0] {R0, R1} resp_e;
  typedef struct packed { logic [3:0] a; op_e o; } item_s;
  typedef bit [7:0] vec_t;
endpackage
package agent_pkg;
  import types_pkg::*;
  class A;
    item_s it;
  endclass
endpackage
package env_pkg;
  import agent_pkg::*;
  class E;
    A a;
  endclass
endpackage
module top;
  import env_pkg::*;
  E e;
endmodule
