// § caStructParamIfaceSharesPaOperand289
package pk;
  typedef struct packed { logic [3:0] n; logic [7:0] m; } s_t;
  localparam s_t K = '{n: 4'h6, m: {4'h1, 4'h2}};
endpackage
interface ifc ();
  import pk::*;
  logic [7:0] e;
  assign e = K.m;
endinterface
module dut (output logic [7:0] p);
  ifc u_a ();
  assign p = u_a.e;
endmodule
