// § pkgTransImpAggTd465
// an unpacked struct and an enum used by a class in the outer package
package types_pkg;
  typedef enum {IDLE, SINGLE, BURST4} op_e;
  typedef struct { int a; op_e o; } u_s;
endpackage
package agent_pkg;
  import types_pkg::*;
  class A; op_e o; endclass
endpackage
package env_pkg;
  import agent_pkg::*;
  class E; A a; endclass
endpackage
module top;
  import env_pkg::*;
  E e;
endmodule
