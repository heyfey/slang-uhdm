// § caIfaceSelLhsTakesSharedRhs289
package pk;
  typedef struct packed { logic [3:0] n; logic [7:0] m; logic [11:0] w; } s_t;
  localparam s_t K = '{n: 4'h6, m: 8'b1100_0011, w: 12'h5A3};
endpackage
interface ifc ();
  import pk::*;
  logic [15:0] e;
  logic [7:0] f;
  assign e[11:4] = K.m;
  assign f = K.m;
endinterface
module dut (output logic [15:0] p, output logic [7:0] q);
  ifc u_a ();
  assign p = u_a.e;
  assign q = u_a.f;
endmodule
