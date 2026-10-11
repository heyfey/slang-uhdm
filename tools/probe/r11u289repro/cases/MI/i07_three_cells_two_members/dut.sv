// § caStructParamIfaceCloneReused289
package pk;
  typedef struct packed { logic [7:0] n; logic [7:0] m; } s_t;
endpackage
interface ifc #(parameter pk::s_t C = '{n: 8'd6, m: {4'h1, 4'h2}}) ();
  logic [31:0] d;
  logic [7:0] e;
  logic [15:0] f;
  assign d = C.n;
  assign e = C.m;
  assign f = C.n;
endinterface
module dut (output logic [31:0] o, output logic [15:0] q);
  ifc u_a ();
  ifc u_b ();
  assign o = u_a.d ^ u_b.e;
  assign q = u_a.f ^ u_b.f;
endmodule
