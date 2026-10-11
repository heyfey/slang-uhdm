// § caStructParamIfaceCloneReused289
package pk;
  typedef struct packed { logic [3:0] n; logic [7:0] m; } s_t;
endpackage
interface ifc #(parameter pk::s_t C = '{n: 4'h6, m: {4'h1, 4'h2}}) ();
  logic [15:0] d;
  logic [7:0] e;
  assign d = C.n;
  assign e = C.m;
endinterface
module dut (output logic [15:0] o, output logic [7:0] p, output logic [15:0] q);
  ifc u_a ();
  ifc u_b ();
  assign o = u_a.d;
  assign p = u_a.e;
  assign q = u_b.d;
endmodule
