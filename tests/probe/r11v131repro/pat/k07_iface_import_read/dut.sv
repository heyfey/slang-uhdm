// § pkgPatReadTsNoParent131
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  parameter s_t P = '{a: 4'h1, b: 4'h2};
endpackage
interface ifc ();
  import pk::*;
  logic [7:0] d;
  assign d = P;
endinterface
module top ();
  ifc u();
endmodule
