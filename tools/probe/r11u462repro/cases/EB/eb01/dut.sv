// § enumBaseInstFollowsEnum462
package types_pkg;
  typedef enum logic [2:0] { OK, ERR } resp_e;
endpackage
package agent_pkg;
  import types_pkg::*;
  class A;
    resp_e r;
  endclass
endpackage
package env_pkg;
  import agent_pkg::*;
  class E;
    A a;
  endclass
endpackage
module top_tb;
  import env_pkg::*;
  E e;
endmodule
