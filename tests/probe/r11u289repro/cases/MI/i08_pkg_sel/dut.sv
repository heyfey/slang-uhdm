// § caIfaceSelLhsTakesSharedRhs289
package pk;
  typedef struct packed { logic [3:0] n; logic [7:0] m; } s_t;
  localparam s_t K = '{n: 4'h6, m: {4'h1, 4'h2}};
endpackage
interface ifc ();
  import pk::*;
  logic [15:0] e;
  logic [3:0] b;
  assign e[7:0] = K.m;
  assign b[1] = K.n;
endinterface
module dut (output logic [15:0] p, output logic [3:0] q);
  ifc u_a ();
  assign p = u_a.e;
  assign q = u_a.b;
endmodule
